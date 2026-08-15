class VideoSession {
  final int id;
  final String meetingPlatform;
  final String meetingLink;
  final String meetingScheduledAt;
  final String meetingStatus;
  final int durationMinutes;
  final String caseTitle;
  final String? assignedTo;

  const VideoSession({
    required this.id,
    required this.meetingPlatform,
    required this.meetingLink,
    required this.meetingScheduledAt,
    required this.meetingStatus,
    required this.durationMinutes,
    required this.caseTitle,
    this.assignedTo,
  });

  factory VideoSession.fromJson(Map<String, dynamic> json) {
    return VideoSession(
      id: int.parse(json['id'].toString()),
      meetingPlatform: json['meeting_platform'] as String? ?? '',
      meetingLink: json['meeting_link'] as String? ?? '',
      meetingScheduledAt: json['meeting_scheduled_at'] as String? ?? '',
      meetingStatus: json['meeting_status'] as String? ?? 'pending',
      durationMinutes: json['duration_minutes'] != null ? int.parse(json['duration_minutes'].toString()) : 60,
      caseTitle: json['case_title'] as String? ?? '',
      assignedTo: json['assigned_to'] as String?,
    );
  }
}
