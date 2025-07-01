import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_stand/providers/providers.dart';
import 'package:auto_stand/widgets/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsProvider);
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 AutoStand',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),
                    const SizedBox(height: 8),
                    Text(
                      'Kill your standup with AI-generated team digests',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: -0.2),
                  ],
                ),
              ),
            ),
            
            if (teams.isEmpty) ...[
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ).animate().scale(delay: 200.ms, duration: 400.ms),
                      const SizedBox(height: 24),
                      Text(
                        'No teams yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first team to get started',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () => context.push('/setup'),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Team'),
                      ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ] else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final team = teams[index];
                      return TeamCard(
                        team: team,
                        onTap: () => context.push('/team/${team.id}'),
                      ).animate().fadeIn(
                        delay: (200 + index * 50).ms,
                        duration: 300.ms,
                      ).slideY(begin: 0.1);
                    },
                    childCount: teams.length,
                  ),
                ),
              ),
            ],
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: teams.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/setup'),
              icon: const Icon(Icons.add),
              label: const Text('New Team'),
            ).animate().scale(delay: 500.ms, duration: 300.ms)
          : null,
    );
  }
}