import 'dart:async';

import 'package:flutter/services.dart';

import 'shared_file_receiver.dart';

/// Android implementation of [SharedFileReceiver] over the
/// `com.dianduji/dian_du_ji/shared_files/events` event channel.
///
/// The native side buffers every event (cold-start intents included) until
/// the first listener attaches and then flushes the buffer exactly once, so
/// `initialize()` is safe to call from every app start.
class AndroidSharedFileReceiver implements SharedFileReceiver {
  AndroidSharedFileReceiver({EventChannel? eventChannel})
    : _eventChannel =
          eventChannel ??
          const EventChannel(SharedFileChannel.eventsName);

  static const String channelName = 'com.dianduji/dian_du_ji/shared_files';

  final EventChannel _eventChannel;
  final _events = StreamController<SharedFileEvent>.broadcast();
  StreamSubscription<dynamic>? _subscription;
  bool _initialized = false;

  @override
  Stream<SharedFileEvent> get events => _events.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is! Map) return;
        final map = Map<String, dynamic>.from(event);
        _events.add(
          SharedFileEvent(
            path: map['path'] as String? ?? '',
            name: map['name'] as String? ?? '\u5206\u4eab\u6587\u4ef6',
            mime: map['mime'] as String?,
            error: map['error'] as String?,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        // Channel teardown or an unexpected native failure; there is nothing
        // importable, and a later share still starts a fresh event stream.
      },
      cancelOnError: false,
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _events.close();
  }
}

/// Names shared with `SharedFileChannel.kt`.
abstract final class SharedFileChannel {
  static const String eventsName =
      'com.dianduji/dian_du_ji/shared_files/events';
}
