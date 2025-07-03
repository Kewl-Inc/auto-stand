import 'package:flutter/material.dart';

enum SectionType {
  pros,
  cons,
  whatWeCanTakeFurther,
  custom
}

class TemplateSection {
  final String id;
  final String title;
  final String description;
  final SectionType type;
  final IconData icon;
  final bool isEnabled;
  final int order;
  final String? customPrompt; // For AI to understand what to look for

  const TemplateSection({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    this.isEnabled = true,
    required this.order,
    this.customPrompt,
  });

  TemplateSection copyWith({
    String? id,
    String? title,
    String? description,
    SectionType? type,
    IconData? icon,
    bool? isEnabled,
    int? order,
    String? customPrompt,
  }) {
    return TemplateSection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
      customPrompt: customPrompt ?? this.customPrompt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'isEnabled': isEnabled,
      'order': order,
      'customPrompt': customPrompt,
    };
  }

  factory TemplateSection.fromJson(Map<String, dynamic> json) {
    return TemplateSection(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: SectionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SectionType.custom,
      ),
      icon: _getIconForType(json['type']),
      isEnabled: json['isEnabled'] ?? true,
      order: json['order'],
      customPrompt: json['customPrompt'],
    );
  }

  static IconData _getIconForType(String typeName) {
    final type = SectionType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => SectionType.custom,
    );
    
    switch (type) {
      case SectionType.pros:
        return Icons.thumb_up_outlined;
      case SectionType.cons:
        return Icons.thumb_down_outlined;
      case SectionType.whatWeCanTakeFurther:
        return Icons.rocket_launch_outlined;
      case SectionType.custom:
        return Icons.add_circle_outline;
    }
  }

  // Default template sections
  static List<TemplateSection> get defaultSections => [
    const TemplateSection(
      id: 'pros',
      title: 'Pros',
      description: 'Positive aspects, strengths, and what\'s working well',
      type: SectionType.pros,
      icon: Icons.thumb_up_outlined,
      order: 0,
      customPrompt: 'What went well or is working? Only mention if truly noteworthy.',
    ),
    const TemplateSection(
      id: 'cons',
      title: 'Cons',
      description: 'Challenges, issues, and areas needing improvement',
      type: SectionType.cons,
      icon: Icons.thumb_down_outlined,
      order: 1,
      customPrompt: 'Real blockers or issues? Skip if everything is fine.',
    ),
    const TemplateSection(
      id: 'what-we-can-take-further',
      title: 'Where We Can Take It Further',
      description: 'Opportunities, next steps, and potential improvements',
      type: SectionType.whatWeCanTakeFurther,
      icon: Icons.rocket_launch_outlined,
      order: 2,
      customPrompt: 'Concrete next steps or opportunities. Be specific and actionable.',
    ),
  ];
}