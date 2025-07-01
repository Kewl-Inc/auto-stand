import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_stand/models/models.dart';
import 'package:auto_stand/providers/providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TemplateSetupPage extends ConsumerStatefulWidget {
  final String teamId;
  
  const TemplateSetupPage({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<TemplateSetupPage> createState() => _TemplateSetupPageState();
}

class _TemplateSetupPageState extends ConsumerState<TemplateSetupPage> {
  late List<TemplateSection> _sections;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final team = ref.read(teamsProvider).firstWhere((t) => t.id == widget.teamId);
    _sections = List.from(team.templateSections);
  }

  void _toggleSection(String sectionId) {
    setState(() {
      final index = _sections.indexWhere((s) => s.id == sectionId);
      if (index != -1) {
        _sections[index] = _sections[index].copyWith(
          isEnabled: !_sections[index].isEnabled,
        );
        _hasChanges = true;
      }
    });
  }

  void _reorderSections(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _sections.removeAt(oldIndex);
      _sections.insert(newIndex, item);
      
      // Update order values
      for (int i = 0; i < _sections.length; i++) {
        _sections[i] = _sections[i].copyWith(order: i);
      }
      _hasChanges = true;
    });
  }

  void _saveChanges() {
    ref.read(teamsProvider.notifier).updateTemplateSections(
      widget.teamId,
      _sections,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Setup'),
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveChanges : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configure Update Sections',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose and order the sections for your daily updates',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _sections.length,
              onReorder: _reorderSections,
              itemBuilder: (context, index) {
                final section = _sections[index];
                return _SectionTile(
                  key: ValueKey(section.id),
                  section: section,
                  onToggle: () => _toggleSection(section.id),
                ).animate().fadeIn(
                  delay: (100 + index * 50).ms,
                  duration: 300.ms,
                ).slideX(begin: 0.2);
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Add custom section
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Custom Section'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final TemplateSection section;
  final VoidCallback onToggle;

  const _SectionTile({
    super.key,
    required this.section,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          section.icon,
          color: section.isEnabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
        title: Text(
          section.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: section.isEnabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        subtitle: Text(
          section.description,
          style: TextStyle(
            fontSize: 13,
            color: section.isEnabled
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: section.isEnabled,
              onChanged: (_) => onToggle(),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.drag_handle,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
        onTap: onToggle,
      ),
    );
  }
}