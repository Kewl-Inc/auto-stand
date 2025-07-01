import 'package:flutter/material.dart';

enum SectionType {
  whatIDid,
  blockers,
  whatILearned,
  showAndTell,
  prototypeLinks,
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
      case SectionType.whatIDid:
        return Icons.check_circle_outline;
      case SectionType.blockers:
        return Icons.block;
      case SectionType.whatILearned:
        return Icons.lightbulb_outline;
      case SectionType.showAndTell:
        return Icons.image_outlined;
      case SectionType.prototypeLinks:
        return Icons.link;
      case SectionType.custom:
        return Icons.add_circle_outline;
    }
  }

  // Default template sections
  static List<TemplateSection> get defaultSections => [
    const TemplateSection(
      id: 'what-i-did',
      title: 'What I did',
      description: 'Summary of completed work and progress',
      type: SectionType.whatIDid,
      icon: Icons.check_circle_outline,
      order: 0,
      customPrompt: 'Summarize work completed, commits made, documents written, meetings attended',
    ),
    const TemplateSection(
      id: 'blockers',
      title: 'What I\'m blocked by',
      description: 'Current blockers and dependencies',
      type: SectionType.blockers,
      icon: Icons.block,
      order: 1,
      customPrompt: 'Identify blockers, dependencies, questions asked, help needed',
    ),
    const TemplateSection(
      id: 'what-i-learned',
      title: 'What I learned',
      description: 'New insights and learnings',
      type: SectionType.whatILearned,
      icon: Icons.lightbulb_outline,
      order: 2,
      customPrompt: 'Extract learnings, insights, discoveries, aha moments',
    ),
    const TemplateSection(
      id: 'show-and-tell',
      title: 'Show & Tell',
      description: 'Screenshots, designs, and visual updates',
      type: SectionType.showAndTell,
      icon: Icons.image_outlined,
      order: 3,
      customPrompt: 'Collect screenshots, Figma links, Loom videos, visual artifacts',
    ),
    const TemplateSection(
      id: 'prototype-links',
      title: 'Prototype links',
      description: 'Links to working prototypes and demos',
      type: SectionType.prototypeLinks,
      icon: Icons.link,
      order: 4,
      customPrompt: 'Find deployed apps, staging links, PR previews, demo videos',
    ),
  ];
}