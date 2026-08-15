class CounselingCase {
  final int id;
  final String category;
  final String title;
  final String status;
  final String priority;
  final String? assignedTo;
  final String openedAt;
  final String? nextFollowup;

  const CounselingCase({
    required this.id,
    required this.category,
    required this.title,
    required this.status,
    required this.priority,
    this.assignedTo,
    required this.openedAt,
    this.nextFollowup,
  });

  factory CounselingCase.fromJson(Map<String, dynamic> json) {
    return CounselingCase(
      id: int.parse(json['id'].toString()),
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'normal',
      assignedTo: json['assigned_to'] as String?,
      openedAt: json['opened_at'] as String? ?? '',
      nextFollowup: json['next_followup'] as String?,
    );
  }
}
