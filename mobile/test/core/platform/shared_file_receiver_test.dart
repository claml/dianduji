import 'package:dian_du_ji/core/platform/android_shared_file_receiver.dart';
import 'package:dian_du_ji/core/platform/shared_file_receiver.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const eventsName = SharedFileChannel.eventsName;
  final messenger = TestDefaultBinaryMessengerBinding.instance
      .defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockStreamHandler(const EventChannel(eventsName), null);
  });

  testWidgets('buffered cold-start events are replayed exactly once', (
    tester,
  ) async {
    var listenerCalls = 0;
    messenger.setMockStreamHandler(
      const EventChannel(eventsName),
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          listenerCalls += 1;
          events.success({
            'path': '/cache/abc123.bin',
            'name': 'lesson.txt',
            'mime': 'text/plain',
          });
        },
        onCancel: (arguments) {},
      ),
    );
    final receiver = AndroidSharedFileReceiver(
      eventChannel: const EventChannel(eventsName),
    );
    addTearDown(receiver.dispose);
    final received = <SharedFileEvent>[];
    final subscription = receiver.events.listen(received.add);
    addTearDown(subscription.cancel);

    await receiver.initialize();
    await tester.pump();

    expect(received, hasLength(1));
    expect(received.single.path, '/cache/abc123.bin');
    expect(received.single.name, 'lesson.txt');
    expect(received.single.mime, 'text/plain');
    expect(received.single.isSupportedDocument, isTrue);

    // A second initialize must not attach another native listener, so a
    // buffered event can never be delivered twice.
    await receiver.initialize();
    await tester.pump();
    expect(listenerCalls, 1);
    expect(received, hasLength(1));
  });

  testWidgets('warm-start events delivered after initialization stream live', (
    tester,
  ) async {
    late MockStreamHandlerEventSink nativeSink;
    messenger.setMockStreamHandler(
      const EventChannel(eventsName),
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          nativeSink = events;
        },
        onCancel: (arguments) {},
      ),
    );
    final receiver = AndroidSharedFileReceiver(
      eventChannel: const EventChannel(eventsName),
    );
    addTearDown(receiver.dispose);
    final received = <SharedFileEvent>[];
    final subscription = receiver.events.listen(received.add);
    addTearDown(subscription.cancel);
    await receiver.initialize();
    await tester.pump();

    nativeSink.success({
      'path': '/cache/def456.bin',
      'name': 'paper.docx',
      'mime': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    });
    await tester.pump();

    expect(received, hasLength(1));
    expect(received.single.path, '/cache/def456.bin');
    expect(received.single.isSupportedDocument, isTrue);
  });

  testWidgets('unknown event payloads are ignored without throwing', (
    tester,
  ) async {
    late MockStreamHandlerEventSink nativeSink;
    messenger.setMockStreamHandler(
      const EventChannel(eventsName),
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          nativeSink = events;
        },
        onCancel: (arguments) {},
      ),
    );
    final receiver = AndroidSharedFileReceiver(
      eventChannel: const EventChannel(eventsName),
    );
    addTearDown(receiver.dispose);
    final received = <SharedFileEvent>[];
    final subscription = receiver.events.listen(received.add);
    addTearDown(subscription.cancel);
    await receiver.initialize();
    await tester.pump();

    nativeSink.success('not-a-map');
    nativeSink.success(null);
    await tester.pump();

    expect(received, isEmpty);
  });

  testWidgets('native error events surface as failures with the message', (
    tester,
  ) async {
    late MockStreamHandlerEventSink nativeSink;
    messenger.setMockStreamHandler(
      const EventChannel(eventsName),
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          nativeSink = events;
        },
        onCancel: (arguments) {},
      ),
    );
    final receiver = AndroidSharedFileReceiver(
      eventChannel: const EventChannel(eventsName),
    );
    addTearDown(receiver.dispose);
    final received = <SharedFileEvent>[];
    final subscription = receiver.events.listen(received.add);
    addTearDown(subscription.cancel);
    await receiver.initialize();
    await tester.pump();

    nativeSink.success({
      'error': 'permission_revoked',
      'name': 'locked.pdf',
      'mime': 'application/pdf',
    });
    await tester.pump();

    expect(received, hasLength(1));
    expect(received.single.isFailure, isTrue);
    expect(received.single.error, 'permission_revoked');
    expect(received.single.path, isEmpty);
  });

  test('noop receiver never emits and initializes silently', () async {
    const receiver = NoopSharedFileReceiver();
    await receiver.initialize();
    final events = <SharedFileEvent>[];
    final subscription = receiver.events.listen(events.add);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    expect(events, isEmpty);
  });
}
