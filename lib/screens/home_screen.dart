import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../screens/manage_projects_screen.dart';
import '../screens/manage_tasks_screen.dart';
import '../screens/add_time_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context),
        drawer: _buildDrawer(context),
        floatingActionButton: _buildFAB(context),
        body: const TabBarView(
          children: [_AllEntriesTab(), _GroupedByProjectsTab()],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Time Tracking'),
      centerTitle: true,
      bottom: const TabBar(
        tabs: [
          Tab(text: 'All Entries'),
          Tab(text: 'Grouped by Projects'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Consumer3<TimeEntryProvider, ProjectProvider, TaskProvider>(
      builder: (context, timeEntryProvider, projectProvider, taskProvider, _) {
        return Drawer(
          child: Column(
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text('Menu', style: TextStyle(fontSize: 24)),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _DrawerItem(
                      icon: Icons.folder_copy_outlined,
                      title: 'Projects',
                      subtitle: '${projectProvider.projects.length} projects',
                      onTap: () => _navigateToProjects(context),
                    ),
                    _DrawerItem(
                      icon: Icons.task_outlined,
                      title: 'Tasks',
                      subtitle: '${taskProvider.tasks.length} tasks',
                      onTap: () => _navigateToTasks(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddEntry(context),
      label: const Text('Add Entry'),
      icon: const Icon(Icons.add),
    );
  }

  void _navigateToProjects(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageProjectsScreen()),
    );
  }

  void _navigateToTasks(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageTasksScreen()),
    );
  }

  void _navigateToAddEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTimeEntryScreen()),
    );
  }
}

class _AllEntriesTab extends StatelessWidget {
  const _AllEntriesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null) {
          return _ErrorWidget(
            error: provider.error!,
            onRetry: provider.refreshTimeEntries,
          );
        }
        if (provider.timeEntries.isEmpty) return const _EmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.timeEntries.length,
          itemBuilder: (context, index) =>
              _TimeEntryCard(entry: provider.timeEntries[index]),
        );
      },
    );
  }
}

class _GroupedByProjectsTab extends StatelessWidget {
  const _GroupedByProjectsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProjectProvider, TimeEntryProvider>(
      builder: (context, projectProvider, timeEntryProvider, _) {
        if (projectProvider.isLoading || timeEntryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (projectProvider.projects.isEmpty) {
          return _NoProjectsState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projectProvider.projects.length,
          itemBuilder: (context, index) {
            final project = projectProvider.projects[index];
            final entries = timeEntryProvider.getTimeEntriesByProjectId(
              project.id!,
            );

            if (entries.isEmpty) return const SizedBox.shrink();

            return _ProjectCard(project: project, entries: entries);
          },
        );
      },
    );
  }
}

class _TimeEntryCard extends StatelessWidget {
  final dynamic entry;

  const _TimeEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final project = context.read<ProjectProvider>().getProjectById(
      entry.projectId,
    );
    final task = context.read<TaskProvider>().getTaskById(entry.taskId);

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task?.name ?? 'Unknown Task',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project?.name ?? 'Unknown Project',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.duration} hours',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(entry.date),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(context, entry.id),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showEditDialog(context, entry),
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            if (entry.note?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.note,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  void _showDeleteDialog(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this time entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TimeEntryProvider>().deleteTimeEntry(entryId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTimeEntryScreen(timeEntry: entry)),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final dynamic project;
  final List<dynamic> entries;

  const _ProjectCard({required this.project, required this.entries});

  @override
  Widget build(BuildContext context) {
    final totalDuration = entries.fold(
      0.0,
      (sum, entry) => sum + (entry.duration ?? 0),
    );

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: project.isDefault == true
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.folder,
                    color: project.isDefault == true
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name ?? 'Unnamed Project',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entries.length} entries • ${totalDuration.toStringAsFixed(1)} hours',
                      ),
                    ],
                  ),
                ),
                if (project.isDefault == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Default',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            ...entries.map((entry) {
              final task = context.read<TaskProvider>().getTaskById(
                entry.taskId,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.task,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task?.name ?? 'Unknown Task',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.duration} hours',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(entry.date),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showDeleteDialog(context, entry.id),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _showEditDialog(context, entry),
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  void _showDeleteDialog(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this time entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TimeEntryProvider>().deleteTimeEntry(entryId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTimeEntryScreen(timeEntry: entry)),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          const Text('Something went wrong'),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          const Text('No time entries yet'),
          const SizedBox(height: 8),
          const Text('Start tracking your time by adding your first entry'),
        ],
      ),
    );
  }
}

class _NoProjectsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text('No projects yet'),
          const SizedBox(height: 8),
          const Text('Create your first project to get started'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageProjectsScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
          ),
        ],
      ),
    );
  }
}
