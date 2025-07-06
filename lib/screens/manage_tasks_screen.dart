import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';

class ManageTasksScreen extends StatelessWidget {
  const ManageTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tasks'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
      body: Consumer2<TaskProvider, ProjectProvider>(
        builder: (context, taskProvider, projectProvider, _) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.tasks.isEmpty) {
            return _EmptyState(onAddTask: () => _showAddTaskDialog(context));
          }

          return ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              final project = projectProvider.getProjectById(task.projectId!);

              return _TaskTile(
                task: task,
                project: project,
                onEdit: () => _showEditTaskDialog(context, task),
                onDelete: () =>
                    _showDeleteTaskDialog(context, task, taskProvider),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _TaskDialog(
        title: 'Add Task',
        onSave: (name, projectId) {
          context.read<TaskProvider>().addTask(name, projectId);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, dynamic task) {
    showDialog(
      context: context,
      builder: (context) => _TaskDialog(
        title: 'Edit Task',
        initialName: task.name,
        initialProjectId: task.projectId,
        onSave: (name, projectId) {
          final updatedTask = task.copyWith(name: name, projectId: projectId);
          context.read<TaskProvider>().updateTask(updatedTask);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteTaskDialog(
    BuildContext context,
    dynamic task,
    TaskProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This will also delete all associated time entries.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteTask(task.id!);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final dynamic task;
  final dynamic project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.task,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(task.name ?? 'Unnamed Task'),
        subtitle: Text(project?.name ?? 'Unknown Project'),
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

class _TaskDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialProjectId;
  final Function(String name, String projectId) onSave;

  const _TaskDialog({
    required this.title,
    this.initialName,
    this.initialProjectId,
    required this.onSave,
  });

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _selectedProjectId = widget.initialProjectId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, _) {
        if (projectProvider.projects.isEmpty) {
          return AlertDialog(
            title: const Text('No Projects'),
            content: const Text(
              'You need to create a project first before adding tasks.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }

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
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    border: OutlineInputBorder(),
                  ),
                  items: projectProvider.projects.map((project) {
                    return DropdownMenuItem(
                      value: project.id,
                      child: Text(project.name ?? 'Unnamed Project'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a project';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(onPressed: _saveTask, child: const Text('Save')),
          ],
        );
      },
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate() && _selectedProjectId != null) {
      widget.onSave(_nameController.text.trim(), _selectedProjectId!);
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTask;

  const _EmptyState({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('No tasks yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Create your first task to get started',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
