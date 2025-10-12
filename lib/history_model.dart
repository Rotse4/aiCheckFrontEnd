class HistoryItem {
  final int id;
  final double aiProbability;
  final String reasoning;
  final DateTime? createdAt;
  final String? essayText;

  HistoryItem({
    required this.id,
    required this.aiProbability,
    required this.reasoning,
    required this.createdAt,
    this.essayText,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final rawProb = json['ai_probability'];
    double prob;
    if (rawProb is num) {
      prob = rawProb.toDouble();
    } else if (rawProb is String) {
      prob = double.tryParse(rawProb) ?? 0.0;
    } else {
      prob = 0.0;
    }
    return HistoryItem(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      aiProbability: prob,
      reasoning: json['reasoning']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      essayText: json['essay_text']?.toString(),
    );
  }

  double get aiPercent => aiProbability * 100.0;
  double get humanProbability => 1.0 - aiProbability;
  double get humanPercent => humanProbability * 100.0;
}