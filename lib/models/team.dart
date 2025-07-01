import 'package:auto_stand/models/template_section.dart';

class Team {
  final String id;
  final String name;
  final String description;
  final List<String> memberIds;
  final String ownerId;
  final List<TemplateSection> templateSections;
  final TeamSettings settings;
  final DateTime createdAt;
  final DateTime? lastDigestAt;

  const Team({
    required this.id,
    required this.name,
    required this.description,
    required this.memberIds,
    required this.ownerId,
    required this.templateSections,
    required this.settings,
    required this.createdAt,
    this.lastDigestAt,
  });

  Team copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? memberIds,
    String? ownerId,
    List<TemplateSection>? templateSections,
    TeamSettings? settings,
    DateTime? createdAt,
    DateTime? lastDigestAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      ownerId: ownerId ?? this.ownerId,
      templateSections: templateSections ?? this.templateSections,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      lastDigestAt: lastDigestAt ?? this.lastDigestAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'ownerId': ownerId,
      'templateSections': templateSections.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastDigestAt': lastDigestAt?.toIso8601String(),
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      memberIds: List<String>.from(json['memberIds']),
      ownerId: json['ownerId'],
      templateSections: (json['templateSections'] as List)
          .map((e) => TemplateSection.fromJson(e))
          .toList(),
      settings: TeamSettings.fromJson(json['settings']),
      createdAt: DateTime.parse(json['createdAt']),
      lastDigestAt: json['lastDigestAt'] != null 
          ? DateTime.parse(json['lastDigestAt']) 
          : null,
    );
  }
}

class TeamSettings {
  final String timezone;
  final String digestTime; // HH:mm format
  final List<int> workDays; // 1-7 (Monday-Sunday)
  final DigestDelivery deliveryMethod;
  final String? slackWebhook;
  final List<String> emailRecipients;
  final bool autoRemind;
  final int reminderHoursBefore;

  const TeamSettings({
    this.timezone = 'America/Los_Angeles',
    this.digestTime = '09:00',
    this.workDays = const [1, 2, 3, 4, 5], // Mon-Fri
    this.deliveryMethod = DigestDelivery.inApp,
    this.slackWebhook,
    this.emailRecipients = const [],
    this.autoRemind = true,
    this.reminderHoursBefore = 2,
  });

  TeamSettings copyWith({
    String? timezone,
    String? digestTime,
    List<int>? workDays,
    DigestDelivery? deliveryMethod,
    String? slackWebhook,
    List<String>? emailRecipients,
    bool? autoRemind,
    int? reminderHoursBefore,
  }) {
    return TeamSettings(
      timezone: timezone ?? this.timezone,
      digestTime: digestTime ?? this.digestTime,
      workDays: workDays ?? this.workDays,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      slackWebhook: slackWebhook ?? this.slackWebhook,
      emailRecipients: emailRecipients ?? this.emailRecipients,
      autoRemind: autoRemind ?? this.autoRemind,
      reminderHoursBefore: reminderHoursBefore ?? this.reminderHoursBefore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timezone': timezone,
      'digestTime': digestTime,
      'workDays': workDays,
      'deliveryMethod': deliveryMethod.name,
      'slackWebhook': slackWebhook,
      'emailRecipients': emailRecipients,
      'autoRemind': autoRemind,
      'reminderHoursBefore': reminderHoursBefore,
    };
  }

  factory TeamSettings.fromJson(Map<String, dynamic> json) {
    return TeamSettings(
      timezone: json['timezone'] ?? 'America/Los_Angeles',
      digestTime: json['digestTime'] ?? '09:00',
      workDays: List<int>.from(json['workDays'] ?? [1, 2, 3, 4, 5]),
      deliveryMethod: DigestDelivery.values.firstWhere(
        (e) => e.name == json['deliveryMethod'],
        orElse: () => DigestDelivery.inApp,
      ),
      slackWebhook: json['slackWebhook'],
      emailRecipients: List<String>.from(json['emailRecipients'] ?? []),
      autoRemind: json['autoRemind'] ?? true,
      reminderHoursBefore: json['reminderHoursBefore'] ?? 2,
    );
  }
}

enum DigestDelivery {
  inApp,
  slack,
  email,
  all
}