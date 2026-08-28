// Models cho Polls — khớp BE `polls` module.
class PollOption {
  final String id;
  final String text;
  final String? emoji;
  final int voteCount;

  const PollOption({
    required this.id,
    required this.text,
    this.emoji,
    this.voteCount = 0,
  });

  factory PollOption.fromJson(Map<String, dynamic> j) {
    final count = j['_count'];
    final votes = j['votes'];
    return PollOption(
      id: j['id'] as String,
      text: j['text'] as String? ?? '',
      emoji: j['emoji'] as String?,
      voteCount:
          (count is Map ? count['votes'] as int? : null) ??
          (votes is List ? votes.length : 0),
    );
  }

  PollOption copyWith({int? voteCount}) => PollOption(
    id: id,
    text: text,
    emoji: emoji,
    voteCount: voteCount ?? this.voteCount,
  );
}

class Poll {
  final String id;
  final String question;
  final bool isMultiple;
  final DateTime? closesAt;
  final List<PollOption> options;

  const Poll({
    required this.id,
    required this.question,
    this.isMultiple = false,
    this.closesAt,
    this.options = const [],
  });

  factory Poll.fromJson(Map<String, dynamic> j) => Poll(
    id: j['id'] as String,
    question: j['question'] as String? ?? '',
    isMultiple: j['isMultiple'] as bool? ?? false,
    closesAt: DateTime.tryParse(j['closesAt']?.toString() ?? ''),
    options: (j['options'] as List? ?? [])
        .whereType<Map>()
        .map((e) => PollOption.fromJson(e.cast<String, dynamic>()))
        .toList(),
  );

  int get totalVotes => options.fold(0, (s, o) => s + o.voteCount);

  Poll copyWith({List<PollOption>? options}) => Poll(
    id: id,
    question: question,
    isMultiple: isMultiple,
    closesAt: closesAt,
    options: options ?? this.options,
  );
}
