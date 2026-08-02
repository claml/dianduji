import 'package:dian_du_ji/features/reader/presentation/reader_chrome_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'hides after accumulated downward travel and reveals on upward travel',
    () {
      final chrome = ReaderChromeController(hideThreshold: 24);

      expect(chrome.visible, isTrue);
      chrome.handleContentScroll(10);
      chrome.handleContentScroll(13);
      expect(chrome.visible, isTrue);
      chrome.handleContentScroll(2);
      expect(chrome.visible, isFalse);
      chrome.handleContentScroll(-1);
      expect(chrome.visible, isTrue);
    },
  );

  test('keeps the toolbar visible and resets travel at the content top', () {
    final chrome = ReaderChromeController(hideThreshold: 24);

    chrome.handleContentScroll(20);
    chrome.handleContentScroll(100, atTop: true);
    expect(chrome.visible, isTrue);
    chrome.handleContentScroll(23);
    expect(chrome.visible, isTrue);
  });

  test(
    'notifies only when visibility changes and ignores non-finite deltas',
    () {
      final chrome = ReaderChromeController(hideThreshold: 24);
      var notifications = 0;
      chrome.addListener(() => notifications++);

      chrome.handleContentScroll(0);
      chrome.handleContentScroll(double.nan);
      chrome.handleContentScroll(double.infinity);
      chrome.handleContentScroll(24);
      chrome.handleContentScroll(1);
      chrome.reveal();
      chrome.reveal();

      expect(notifications, 2);
    },
  );
}
