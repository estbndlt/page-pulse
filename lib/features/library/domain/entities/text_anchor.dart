class TextAnchor implements Comparable<TextAnchor> {
  const TextAnchor({
    required this.sectionId,
    required this.paragraphIndex,
    required this.tokenIndex,
    this.characterOffset = 0,
  });

  final String sectionId;
  final int paragraphIndex;
  final int tokenIndex;
  final int characterOffset;

  @override
  int compareTo(TextAnchor other) {
    final section = sectionId.compareTo(other.sectionId);
    if (section != 0) return section;
    final paragraph = paragraphIndex.compareTo(other.paragraphIndex);
    if (paragraph != 0) return paragraph;
    final token = tokenIndex.compareTo(other.tokenIndex);
    if (token != 0) return token;
    return characterOffset.compareTo(other.characterOffset);
  }
}
