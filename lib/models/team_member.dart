class TeamMember {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;
  final Map<String, String> integrations; // platform -> userId/handle
  final DateTime joinedAt;
  final bool isActive;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.integrations,
    required this.joinedAt,
    this.isActive = true,
  });

  TeamMember copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    Map<String, String>? integrations,
    DateTime? joinedAt,
    bool? isActive,
  }) {
    return TeamMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      integrations: integrations ?? this.integrations,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role,
      'integrations': integrations,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      role: json['role'],
      integrations: Map<String, String>.from(json['integrations'] ?? {}),
      joinedAt: DateTime.parse(json['joinedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}