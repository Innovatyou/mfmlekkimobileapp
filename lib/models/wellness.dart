import 'dart:convert';

class WellnessProfile {
  final int score;
  final String grade;
  final List<String> flags;
  final List<CareEvent> careEvents;
  final ActivitySummary activity;
  final DateTime? lastCareAt;

  const WellnessProfile({
    required this.score,
    required this.grade,
    required this.flags,
    required this.careEvents,
    required this.activity,
    this.lastCareAt,
  });

  factory WellnessProfile.fromJson(Map<String, dynamic> json) {
    return WellnessProfile(
      score: (json['score'] as num?)?.toInt() ?? 0,
      grade: json['grade'] as String? ?? 'none',
      flags: List<String>.from(json['flags'] as List? ?? []),
      careEvents: (json['care_events'] as List? ?? [])
          .map((e) => CareEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      activity: ActivitySummary.fromJson(
          json['activity'] as Map<String, dynamic>? ?? {}),
      lastCareAt: json['last_care_at'] != null
          ? DateTime.tryParse(json['last_care_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'grade': grade,
        'flags': flags,
        'care_events': careEvents.map((e) => e.toJson()).toList(),
        'activity': activity.toJson(),
        'last_care_at': lastCareAt?.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory WellnessProfile.fromJsonString(String s) =>
      WellnessProfile.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

class CareEvent {
  final String eventType;
  final String note;
  final String createdBy;
  final DateTime createdAt;

  const CareEvent({
    required this.eventType,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  factory CareEvent.fromJson(Map<String, dynamic> json) => CareEvent(
        eventType: json['event_type'] as String? ?? 'other',
        note: json['note'] as String? ?? '',
        createdBy: json['created_by'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'event_type': eventType,
        'note': note,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}

class ActivitySummary {
  final int groupsCount;
  final int prayersCount;
  final int testimonyCount;
  final int donationCount;

  const ActivitySummary({
    required this.groupsCount,
    required this.prayersCount,
    required this.testimonyCount,
    required this.donationCount,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) =>
      ActivitySummary(
        groupsCount: (json['groups_count'] as num?)?.toInt() ?? 0,
        prayersCount: (json['prayers_count'] as num?)?.toInt() ?? 0,
        testimonyCount: (json['testimony_count'] as num?)?.toInt() ?? 0,
        donationCount: (json['donation_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'groups_count': groupsCount,
        'prayers_count': prayersCount,
        'testimony_count': testimonyCount,
        'donation_count': donationCount,
      };
}

class BirthdayMember {
  final String firstname;
  final String? thumbnail;
  final String bdayLabel;
  final int daysUntil;

  const BirthdayMember({
    required this.firstname,
    this.thumbnail,
    required this.bdayLabel,
    required this.daysUntil,
  });

  factory BirthdayMember.fromJson(Map<String, dynamic> json) => BirthdayMember(
        firstname: json['firstname'] as String? ?? '',
        thumbnail: json['thumbnail'] as String?,
        bdayLabel: json['bday_label'] as String? ?? '',
        daysUntil: (json['days_until'] as num?)?.toInt() ?? 0,
      );
}
