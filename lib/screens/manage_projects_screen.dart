import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';

class ManageProjectsScreen extends StatelessWidget {
  const ManageProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Projects'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectDialog(context),
        label: const Text('Add Project'),
        icon: const Icon(Icons.add),
      ),
      body: Consumer2<ProjectProvider, TaskProvider>(
        builder: (context, projectProvider, taskProvider, _) {
          if (projectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (projectProvider.projects.isEmpty) {
            return _EmptyState(
              onAddProject: () => _showAddProjectDialog(context),
            );
          }

          return ListView.builder(
            itemCount: projectProvider.projects.length,
            itemBuilder: (context, index) {
              final project = projectProvider.projects[index];
              final taskCount = taskProvider
                  .getTasksByProjectId(project.id!)
                  .length;

              return _ProjectTile(
                project: project,
                taskCount: taskCount,
                onEdit: () => _showEditProjectDialog(context, project),
                onDelete: () =>
                    _showDeleteProjectDialog(context, project, projectProvider),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ProjectDialog(
        title: 'Add Project',
        projectId: null, // New project has no ID
        onSave: (name, isDefault) {
          context.read<ProjectProvider>().addProject(
            name,
            isDefault: isDefault,
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, dynamic project) {
    showDialog(
      context: context,
      builder: (context) => _ProjectDialog(
        title: 'Edit Project',
        initialName: project.name,
        initialIsDefault: project.isDefault == true,
        projectId: project.id, // Pass the project ID
        onSave: (name, isDefault) {
          final updatedProject = project.copyWith(
            name: name,
            isDefault: isDefault,
          );
          context.read<ProjectProvider>().updateProject(updatedProject);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteProjectDialog(
    BuildContext context,
    dynamic project,
    ProjectProvider provider,
  ) {
    final taskCount = context
        .read<TaskProvider>()
        .getTasksByProjectId(project.id!)
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          taskCount > 0
              ? 'This project has $taskCount task(s). Deleting it will also delete all associated tasks and time entries. Are you sure?'
              : 'Are you sure you want to delete this project?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteProject(project.id!);
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
}

class _ProjectTile extends StatelessWidget {
  final dynamic project;
  final int taskCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectTile({
    required this.project,
    required this.taskCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
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
        title: Text(
          project.name ?? 'Unnamed Project',
          style: TextStyle(
            fontWeight: project.isDefault == true
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$taskCount task(s)'),
            if (project.isDefault == true) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Default Project',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final bool? initialIsDefault;
  final String?
  projectId; // Add projectId to track which project is being edited
  final Function(String name, bool isDefault) onSave;

  const _ProjectDialog({
    required this.title,
    this.initialName,
    this.initialIsDefault,
    this.projectId, // Add this parameter
    required this.onSave,
  });

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isDefault = false;
  bool _canSetAsDefault = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _isDefault = widget.initialIsDefault ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkDefaultProjectAvailability();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _checkDefaultProjectAvailability() {
    final projectProvider = context.read<ProjectProvider>();
    final currentDefaultProject = projectProvider.getDefaultProject();

    if (widget.projectId != null) {
      // This is an edit dialog for an existing project
      if (currentDefaultProject?.id == widget.projectId) {
        // This project is currently the default - allow unsetting it
        _canSetAsDefault = true;
      } else {
        // This project is not the default - only allow setting as default if no default exists
        _canSetAsDefault = currentDefaultProject == null;
      }
    } else {
      // This is a new project dialog - only allow setting as default if no default exists
      _canSetAsDefault = currentDefaultProject == null;
    }

    // If we can't set as default, ensure the checkbox is unchecked
    if (!_canSetAsDefault) {
      _isDefault = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        return AlertDialog(
          title: Text(widget.title),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Set as default project'),
                  subtitle: _canSetAsDefault
                      ? const Text(
                          'This project will be selected by default when adding time entries',
                        )
                      : const Text(
                          'Another project is already set as default. Unset it first to set this project as default.',
                        ),
                  isThreeLine: true,
                  value: _isDefault,
                  onChanged: _canSetAsDefault
                      ? (value) {
                          setState(() {
                            _isDefault = value ?? false;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(onPressed: _saveProject, child: const Text('Save')),
          ],
        );
      },
    );
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_nameController.text.trim(), _isDefault);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddProject;

  const _EmptyState({required this.onAddProject});

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
          Text(
            'No projects yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project to get started',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
