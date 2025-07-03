import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_stand/config/api_config.dart';
import 'package:auto_stand/models/models.dart';

class AIService {
  static const String _openAIBaseUrl = 'https://api.openai.com/v1';
  
  static String get _apiKey {
    try {
      // First try to get from environment variable
      final envKey = dotenv.env['OPENAI_API_KEY'];
      if (envKey != null && envKey.isNotEmpty && envKey != 'your-openai-api-key-here') {
        return envKey;
      }
      // Fall back to ApiConfig
      return ApiConfig.openAIApiKey;
    } catch (e) {
      // Fallback for web or when dotenv is not initialized
      return ApiConfig.openAIApiKey;
    }
  }

  /// Parse content from various sources and generate standup update
  static Future<StandupUpdate?> generateStandupUpdate({
    required String teamMemberId,
    required List<DataSource> dataSources,
    required List<TemplateSection> templateSections,
    required DateTime date,
  }) async {
    try {
      debugPrint('Starting standup generation...');
      debugPrint('Data sources count: ${dataSources.length}');
      
      // Fetch content from data sources
      final rawContent = await _fetchAndCombineContent(dataSources);
      
      debugPrint('Raw content length: ${rawContent.length}');
      
      if (rawContent.isEmpty) {
        debugPrint('No content found from data sources');
        return null;
      }

      // Generate sections based on template
      final sections = await _generateSections(
        rawContent: rawContent,
        templateSections: templateSections,
      );
      
      debugPrint('Generated sections: ${sections.length}');

      // Create standup update
      return StandupUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teamMemberId: teamMemberId,
        date: date,
        sections: sections,
        dataSources: dataSources,
        createdAt: DateTime.now(),
        rawContent: rawContent,
      );
    } catch (e, stackTrace) {
      debugPrint('Error generating standup update: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow; // Re-throw to see the actual error
    }
  }

  /// Fetch and combine content from multiple data sources
  static Future<String> _fetchAndCombineContent(List<DataSource> sources) async {
    final contentParts = <String>[];
    
    for (final source in sources) {
      try {
        String content = source.content ?? '';
        
        // If content not cached, fetch based on platform
        if (content.isEmpty) {
          content = await _fetchContentFromSource(source);
        }
        
        if (content.isNotEmpty) {
          contentParts.add('=== Content from ${source.platform} ===\n$content\n');
        }
      } catch (e) {
        debugPrint('Error fetching from ${source.platform}: $e');
      }
    }
    
    return contentParts.join('\n');
  }

  /// Fetch content from a specific data source
  static Future<String> _fetchContentFromSource(DataSource source) async {
    // Return the content if it's already provided (for manual notes)
    if (source.content != null && source.content!.isNotEmpty) {
      return source.content!;
    }
    
    // For MVP, parse the URL/content to understand what was done
    final url = source.url.toLowerCase();
    
    if (url.contains('github.com') && url.contains('/pull/')) {
      return 'Worked on pull request: ${source.url}';
    } else if (url.contains('figma.com')) {
      return 'Updated designs in Figma: ${source.url}';
    } else if (url.contains('notion.so')) {
      return 'Updated documentation in Notion: ${source.url}';
    } else if (source.platform == 'notes') {
      return source.content ?? '';
    } else {
      return 'Worked on: ${source.url}';
    }
  }

  /// Generate sections using AI based on raw content and template
  static Future<Map<String, UpdateSection>> _generateSections({
    required String rawContent,
    required List<TemplateSection> templateSections,
  }) async {
    debugPrint('Generating sections with API key: ${_apiKey.substring(0, 10)}...');
    
    if (_apiKey.isEmpty || _apiKey == 'your-openai-api-key-here') {
      throw Exception('OpenAI API key not configured. Please add a valid API key in lib/config/api_config.dart');
    }

    try {
      final enabledSections = templateSections.where((s) => s.isEnabled).toList();
      
      final prompt = _buildPrompt(rawContent, enabledSections);
      
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {
              'role': 'system',
              'content': '''Be ruthlessly concise. Only output sections with real signal.

              Rules:
              • If a section has nothing meaningful, omit it entirely (no empty string — exclude the key)
              • Max 2-3 bullets per section
              • Bullet format: "Key point: short explanation" (max 10 words)
              • No filler, no fluff, no restating input
              • Focus only on what matters for a standup'''
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseAIResponse(content, enabledSections);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('OpenAI API error: ${error['error']['message'] ?? response.body}');
      }
    } catch (e) {
      debugPrint('Error calling OpenAI API: $e');
      rethrow; // Re-throw the error instead of returning mock data
    }
  }

  /// Build prompt for AI
  static String _buildPrompt(String rawContent, List<TemplateSection> sections) {
    return '''
You're given raw activity data. Generate a JSON standup update using only these possible keys:
• "pros": What went well? Only include real wins.
• "cons": What's blocking or broken? Skip if all clear.
• "what-we-can-take-further": Next steps or opportunities. Be specific.

Activity data:
$rawContent

Each section should be in first-person, using "•" or "-" bullets. Keep it natural, useful, and tight — like something you'd say out loud in 30 seconds.

Return only the JSON object — no markdown, no extra text, no empty keys.
''';
  }

  /// Parse AI response into sections
  static Map<String, UpdateSection> _parseAIResponse(
    String response, 
    List<TemplateSection> templateSections,
  ) {
    try {
      // Remove markdown code blocks if present
      String cleanedResponse = response;
      if (response.contains('```json')) {
        cleanedResponse = response
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
      }
      
      final json = jsonDecode(cleanedResponse);
      final sections = <String, UpdateSection>{};
      
      for (final section in templateSections) {
        if (json.containsKey(section.id)) {
          final sectionData = json[section.id];
          
          // Handle both string and array responses
          if (sectionData is List) {
            sections[section.id] = UpdateSection(
              content: '',
              type: section.type,
              bullets: sectionData.map((item) => item.toString()).toList(),
            );
          } else if (sectionData is String) {
            sections[section.id] = UpdateSection(
              content: sectionData,
              type: section.type,
              bullets: _extractBullets(sectionData),
            );
          }
        }
      }
      
      return sections;
    } catch (e) {
      debugPrint('Error parsing AI response: $e');
      debugPrint('Raw response: $response');
      throw Exception('Failed to parse AI response: $e');
    }
  }

  /// Extract bullet points from content
  static List<String> _extractBullets(String content) {
    final lines = content.split('\n');
    return lines
        .where((line) => line.trim().startsWith('•') || line.trim().startsWith('-'))
        .map((line) => line.trim().substring(1).trim())
        .toList();
  }

  /* REMOVED - No mock data allowed
  /// Generate mock sections for development
  static Map<String, UpdateSection> _generateMockSections(
    List<TemplateSection> templateSections,
    {String? rawContent}
  ) {
    final sections = <String, UpdateSection>{};
    
    // Parse the raw content to extract meaningful information
    final lines = rawContent?.split('\n') ?? [];
    final githubPRs = <String>[];
    final figmaLinks = <String>[];
    final otherWork = <String>[];
    final notes = <String>[];
    
    for (final line in lines) {
      if (line.contains('github.com') && line.contains('/pull/')) {
        githubPRs.add(line);
      } else if (line.contains('figma.com')) {
        figmaLinks.add(line);
      } else if (line.contains('Content from notes')) {
        // Extract notes content
        final noteIndex = lines.indexOf(line);
        if (noteIndex < lines.length - 1) {
          notes.add(lines[noteIndex + 1]);
        }
      } else if (line.trim().isNotEmpty && !line.contains('===')) {
        otherWork.add(line);
      }
    }
    
    for (final template in templateSections.where((s) => s.isEnabled)) {
      String content = '';
      List<String> bullets = [];
      
      switch (template.type) {
        case SectionType.whatIDid:
          if (githubPRs.isNotEmpty || figmaLinks.isNotEmpty || otherWork.isNotEmpty) {
            bullets = [];
            if (githubPRs.isNotEmpty) {
              bullets.add('Worked on ${githubPRs.length} pull request${githubPRs.length > 1 ? 's' : ''}');
            }
            if (figmaLinks.isNotEmpty) {
              bullets.add('Updated designs in Figma');
            }
            for (final work in otherWork.take(3)) {
              if (!work.contains('http')) {
                bullets.add(work.trim());
              }
            }
          } else {
            content = 'Made progress on various tasks';
          }
          break;
          
        case SectionType.blockers:
          // Look for blocker keywords in notes
          final blockerKeywords = ['blocked', 'waiting', 'need', 'stuck'];
          final blockers = notes.where((note) => 
            blockerKeywords.any((keyword) => note.toLowerCase().contains(keyword))
          ).toList();
          
          if (blockers.isNotEmpty) {
            bullets = blockers;
          } else {
            content = 'No blockers at this time';
          }
          break;
          
        case SectionType.whatILearned:
          // Look for learning keywords
          final learningKeywords = ['learned', 'discovered', 'realized', 'found out'];
          final learnings = notes.where((note) => 
            learningKeywords.any((keyword) => note.toLowerCase().contains(keyword))
          ).toList();
          
          if (learnings.isNotEmpty) {
            bullets = learnings;
          } else {
            content = 'Continuing to learn and improve';
          }
          break;
          
        case SectionType.showAndTell:
          if (figmaLinks.isNotEmpty || githubPRs.isNotEmpty) {
            content = 'Check out the latest updates!';
            if (figmaLinks.isNotEmpty) {
              bullets.add('New designs: ${figmaLinks.first}');
            }
            if (githubPRs.isNotEmpty) {
              bullets.add('Code changes: ${githubPRs.first}');
            }
          }
          break;
          
        case SectionType.prototypeLinks:
          final links = lines.where((line) => line.contains('http')).take(3).toList();
          if (links.isNotEmpty) {
            bullets = links;
          }
          break;
          
        default:
          content = 'No updates for this section';
      }
      
      sections[template.id] = UpdateSection(
        content: content,
        bullets: bullets,
        type: template.type,
      );
    }
    
    return sections;
  }
  */

  /// Summarize team updates into a digest
  static Future<String> generateTeamDigest({
    required List<StandupUpdate> updates,
    required List<TeamMember> members,
    required DateTime date,
  }) async {
    final digest = StringBuffer();
    
    digest.writeln('# Team Standup - ${_formatDate(date)}');
    digest.writeln();
    
    for (final update in updates) {
      final member = members.firstWhere((m) => m.id == update.teamMemberId);
      digest.writeln('## ${member.name}');
      digest.writeln();
      
      for (final sectionEntry in update.sections.entries) {
        final section = sectionEntry.value;
        digest.writeln('### ${_getSectionTitle(section.type)}');
        digest.writeln(section.content);
        
        if (section.bullets.isNotEmpty) {
          for (final bullet in section.bullets) {
            digest.writeln('• $bullet');
          }
        }
        
        digest.writeln();
      }
      
      digest.writeln('---');
      digest.writeln();
    }
    
    return digest.toString();
  }

  static String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _getSectionTitle(SectionType type) {
    switch (type) {
      case SectionType.pros:
        return 'Pros';
      case SectionType.cons:
        return 'Cons';
      case SectionType.whatWeCanTakeFurther:
        return 'Where We Can Take It Further';
      case SectionType.custom:
        return 'Updates';
    }
  }
}