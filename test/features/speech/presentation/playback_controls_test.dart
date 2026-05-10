import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:page_pulse/features/speech/presentation/playback_controls.dart';

void main() {
  group('PlaybackControls', () {
    testWidgets('delegates button taps to injected callbacks', (tester) async {
      var playPauseCalls = 0;
      var seekBackCalls = 0;
      var seekForwardCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: PlaybackControls(
              onPlayPause: () => playPauseCalls += 1,
              onSeekBack: () => seekBackCalls += 1,
              onSeekForward: () => seekForwardCalls += 1,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(PlaybackControls.playPauseButtonKey));
      await tester.tap(find.byKey(PlaybackControls.seekBackButtonKey));
      await tester.tap(find.byKey(PlaybackControls.seekForwardButtonKey));

      expect(playPauseCalls, 1);
      expect(seekBackCalls, 1);
      expect(seekForwardCalls, 1);
    });

    testWidgets('disables controls while busy', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: PlaybackControls(
              isBusy: true,
              onPlayPause: () {},
              onSeekBack: () {},
              onSeekForward: () {},
            ),
          ),
        ),
      );

      final playButton = tester.widget<IconButton>(
        find.byKey(PlaybackControls.playPauseButtonKey),
      );

      expect(playButton.onPressed, isNull);
    });
  });
}
