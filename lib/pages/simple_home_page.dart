import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_stand/models/models.dart';
import 'package:auto_stand/services/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleHomePage extends ConsumerStatefulWidget {
  const SimpleHomePage({super.key});

  @override
  ConsumerState<SimpleHomePage> createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends ConsumerState<SimpleHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _dataSourcesController = TextEditingController();
  final _nameController = TextEditingController(text: 'Brina');
  
  bool _isGenerating = false;
  String? _generatedUpdate;
  List<TemplateSection> _enabledSections = TemplateSection.defaultSections;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void dispose() {
    _dataSourcesController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName');
    if (savedName != null && savedName.isNotEmpty) {
      _nameController.text = savedName;
    }
  }

  Future<void> _saveUserName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
  }

  Future<void> _generateStandup() async {
    if (!_formKey.currentState!.validate()) return;

    // Save the user's name
    await _saveUserName();

    setState(() {
      _isGenerating = true;
      _generatedUpdate = null;
    });

    try {
      debugPrint('=== Starting standup generation ===');
      // Parse input into data sources
      final sources = _dataSourcesController.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
            final parts = line.split(':');
            return DataSource(
              platform: parts.length > 1 ? parts[0].trim() : 'note',
              url: parts.length > 1 ? parts.sublist(1).join(':').trim() : line.trim(),
              fetchedAt: DateTime.now(),
              content: parts.length > 1 ? null : line.trim(),
            );
          }).toList();


      debugPrint('Total sources: ${sources.length}');
      for (var source in sources) {
        debugPrint('Source - Platform: ${source.platform}, URL: ${source.url}');
      }

      // Generate the standup update
      final update = await AIService.generateStandupUpdate(
        teamMemberId: 'user',
        dataSources: sources,
        templateSections: _enabledSections,
        date: DateTime.now(),
      );

      if (update != null) {
        // Format the update for Slack
        final formatted = _formatForSlack(update);
        setState(() {
          _generatedUpdate = formatted;
        });
      } else {
        debugPrint('Update was null - AI service returned no data');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to generate analysis - AI service error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _generateStandup: $e');
      debugPrint('Stack trace: $stackTrace');
      
      String errorMessage = 'Error: ${e.toString()}';
      if (e.toString().contains('API key') || e.toString().contains('your-openai-api-key-here')) {
        errorMessage = 'OpenAI API key not configured. Please add your API key in lib/config/api_config.dart';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Invalid OpenAI API key';
      } else if (e.toString().contains('429')) {
        errorMessage = 'OpenAI rate limit exceeded';
      } else if (e.toString().contains('Failed to parse')) {
        errorMessage = 'Failed to parse AI response';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  String _formatForSlack(StandupUpdate update) {
    final buffer = StringBuffer();
    
    for (final section in _enabledSections) {
      if (update.sections.containsKey(section.id)) {
        final content = update.sections[section.id]!;
        
        // Section header with emoji
        String emoji = '';
        switch (section.type) {
          case SectionType.pros:
            emoji = '✅';
            break;
          case SectionType.cons:
            emoji = '❌';
            break;
          case SectionType.whatWeCanTakeFurther:
            emoji = '🚀';
            break;
          default:
            emoji = '📌';
        }
        
        buffer.writeln('$emoji *${section.title}*');
        
        if (content.bullets.isNotEmpty) {
          for (final bullet in content.bullets) {
            buffer.writeln('  • $bullet');
          }
        } else {
          buffer.writeln(content.content);
        }
        
        buffer.writeln();
      }
    }
    
    // Add sign-off
    buffer.writeln();
    buffer.writeln('— ${_nameController.text}');
    
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _copyToClipboard() {
    if (_generatedUpdate != null) {
      Clipboard.setData(ClipboardData(text: _generatedUpdate!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard! Ready to paste in Slack.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendToSlack() async {
    if (_generatedUpdate == null) return;
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      final success = await SlackService.sendToSlack(_generatedUpdate!);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully sent to Slack! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send to Slack. Please copy and paste manually.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  '🔧 AutoStand',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),
                const SizedBox(height: 8),
                Text(
                  'Analyze your work and generate insights',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: -0.2),
                
                const SizedBox(height: 32),
                
                // Input Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Data Sources Input
                      Text(
                        'What did you work on?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paste links or describe your work. One item per line.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dataSourcesController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: '''Examples:
github: https://github.com/org/repo/pull/123
figma: https://figma.com/file/abc123
Implemented user authentication
Fixed bug in payment processing
Reviewed 3 PRs''',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please add at least one work item';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Name Input
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your name',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your name',
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _isGenerating ? null : _generateStandup,
                          child: _isGenerating
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Generating...'),
                                  ],
                                )
                              : const Text(
                                  'Generate Analysis',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                
                // Generated Update
                if (_generatedUpdate != null) ...[
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Analysis',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _copyToClipboard,
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Copy to clipboard',
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: _sendToSlack,
                                  icon: const Icon(Icons.send),
                                  label: const Text('Send to Slack'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SelectableText(
                            _generatedUpdate!,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              height: 1.5,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Copy and paste this into Slack!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}