import 'package:auto_stand/models/template_section.dart';

class StandupUpdate {
  final String id;
  final String teamMemberId;
  final DateTime date;
  final Map<String, UpdateSection> sections; // sectionId -> content
  final List<DataSource> dataSources;
  final DateTime createdAt;
  final bool isPublished;
  final String? rawContent; // Original content before AI processing

  const StandupUpdate({
    required this.id,
    required this.teamMemberId,
    required this.date,
    required this.sections,
    required this.dataSources,
    required this.createdAt,
    this.isPublished = false,
    this.rawContent,
  });

  StandupUpdate copyWith({
    String? id,
    String? teamMemberId,
    DateTime? date,
    Map<String, UpdateSection>? sections,
    List<DataSource>? dataSources,
    DateTime? createdAt,
    bool? isPublished,
    String? rawContent,
  }) {
    return StandupUpdate(
      id: id ?? this.id,
      teamMemberId: teamMemberId ?? this.teamMemberId,
      date: date ?? this.date,
      sections: sections ?? this.sections,
      dataSources: dataSources ?? this.dataSources,
      createdAt: createdAt ?? this.createdAt,
      isPublished: isPublished ?? this.isPublished,
      rawContent: rawContent ?? this.rawContent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamMemberId': teamMemberId,
      'date': date.toIso8601String(),
      'sections': sections.map((key, value) => MapEntry(key, value.toJson())),
      'dataSources': dataSources.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isPublished': isPublished,
      'rawContent': rawContent,
    };
  }

  factory StandupUpdate.fromJson(Map<String, dynamic> json) {
    return StandupUpdate(
      id: json['id'],
      teamMemberId: json['teamMemberId'],
      date: DateTime.parse(json['date']),
      sections: (json['sections'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, UpdateSection.fromJson(value)),
      ),
      dataSources: (json['dataSources'] as List)
          .map((e) => DataSource.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      isPublished: json['isPublished'] ?? false,
      rawContent: json['rawContent'],
    );
  }
}

class UpdateSection {
  final String content;
  final List<String> bullets;
  final List<Attachment> attachments;
  final SectionType type;

  const UpdateSection({
    required this.content,
    this.bullets = const [],
    this.attachments = const [],
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'bullets': bullets,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'type': type.name,
    };
  }

  factory UpdateSection.fromJson(Map<String, dynamic> json) {
    return UpdateSection(
      content: json['content'],
      bullets: List<String>.from(json['bullets'] ?? []),
      attachments: (json['attachments'] as List?)
          ?.map((e) => Attachment.fromJson(e))
          .toList() ?? [],
      type: SectionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SectionType.custom,
      ),
    );
  }
}

class Attachment {
  final String type; // image, link, video, file
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;

  const Attachment({
    required this.type,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      type: json['type'],
      url: json['url'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class DataSource {
  final String platform; // github, slack, notion, etc
  final String url;
  final DateTime fetchedAt;
  final String? content; // Cached content

  const DataSource({
    required this.platform,
    required this.url,
    required this.fetchedAt,
    this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
      'fetchedAt': fetchedAt.toIso8601String(),
      'content': content,
    };
  }

  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      platform: json['platform'],
      url: json['url'],
      fetchedAt: DateTime.parse(json['fetchedAt']),
      content: json['content'],
    );
  }
}