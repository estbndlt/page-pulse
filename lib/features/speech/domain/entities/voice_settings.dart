class VoiceSettings {
  const VoiceSettings({
    this.voiceId = 'default',
    this.speakerId = 0,
    this.speed = 1.0,
  });

  final String voiceId;
  final int speakerId;
  final double speed;
}
