import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  final dynamic timeEntry; // Optional time entry for editing

  const AddTimeEntryScreen({super.key, this.timeEntry});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _noteController = TextEditingController();
  
  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.timeEntry != null;
    if (_isEditing) {
      _loadExistingData();
    } else {
      _loadDefaultProject();
    }
  }

  void _loadExistingData() {
    final entry = widget.timeEntry;
    _selectedProjectId = entry.projectId;
    _selectedTaskId = entry.taskId;
    _selectedDate = DateTime.parse(entry.date);
    _durationController.text = entry.duration?.toString() ?? '';
    _noteController.text = entry.note ?? '';
  }

  @override
  void dispose() {
    _durationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadDefaultProject() {
    final projectProvider = context.read<ProjectProvider>();
    if (projectProvider.projects.isNotEmpty) {
      final defaultProject = projectProvider.projects.firstWhere(
        (project) => project.isDefault == true,
        orElse: () => projectProvider.projects.first,
      );
      setState(() {
        _selectedProjectId = defaultProject.id;
        _loadTasksForProject(defaultProject.id!);
      });
    }
  }

  void _loadTasksForProject(String projectId) {
    final taskProvider = context.read<TaskProvider>();
    final tasks = taskProvider.getTasksByProjectId(projectId);
    if (tasks.isNotEmpty) {
      setState(() {
        _selectedTaskId = tasks.first.id;
      });
    } else {
      setState(() {
        _selectedTaskId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Time Entry' : 'Add Time Entry'),
        centerTitle: true,
      ),
      body: Consumer3<ProjectProvider, TaskProvider, TimeEntryProvider>(
        builder: (context, projectProvider, taskProvider, timeEntryProvider, _) {
          if (projectProvider.isLoading || taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (projectProvider.projects.isEmpty) {
            return _NoProjectsState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectDropdown(
                    projects: projectProvider.projects,
                    selectedProjectId: _selectedProjectId,
                    onChanged: (projectId) {
                      setState(() {
                        _selectedProjectId = projectId;
                        _selectedTaskId = null;
                      });
                      if (projectId != null) {
                        _loadTasksForProject(projectId);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _TaskDropdown(
                    tasks: taskProvider.getTasksByProjectId(_selectedProjectId ?? ''),
                    selectedTaskId: _selectedTaskId,
                    onChanged: (taskId) {
                      setState(() {
                        _selectedTaskId = taskId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _DurationField(controller: _durationController),
                  const SizedBox(height: 16),
                  _DatePickerField(
                    selectedDate: _selectedDate,
                    onChanged: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _NoteField(controller: _noteController),
                  const SizedBox(height: 32),
                  _SaveButton(
                    onPressed: () => _saveTimeEntry(timeEntryProvider),
                    isLoading: timeEntryProvider.isLoading,
                    isEditing: _isEditing,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveTimeEntry(TimeEntryProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null || _selectedTaskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project and task')),
      );
      return;
    }

    try {
      final duration = double.parse(_durationController.text);
      final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      if (_isEditing) {
        final updatedEntry = widget.timeEntry.copyWith(
          projectId: _selectedProjectId!,
          taskId: _selectedTaskId!,
          duration: duration,
          date: date,
          note: _noteController.text.trim(),
        );
        await provider.updateTimeEntry(updatedEntry);
      } else {
        await provider.addTimeEntry(
          projectId: _selectedProjectId!,
          taskId: _selectedTaskId!,
          duration: duration,
          date: date,
          note: _noteController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Time entry updated successfully' : 'Time entry added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _ProjectDropdown extends StatelessWidget {
  final List<dynamic> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onChanged;

  const _ProjectDropdown({
    required this.projects,
    required this.selectedProjectId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedProjectId,
      decoration: const InputDecoration(
        labelText: 'Project',
        border: OutlineInputBorder(),
      ),
      items: projects.map((project) {
        return DropdownMenuItem<String>(
          value: project.id,
          child: Text(project.name ?? 'Unnamed Project'),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a project';
        }
        return null;
      },
    );
  }
}

class _TaskDropdown extends StatelessWidget {
  final List<dynamic> tasks;
  final String? selectedTaskId;
  final ValueChanged<String?> onChanged;

  const _TaskDropdown({
    required this.tasks,
    required this.selectedTaskId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.error),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Theme.of(context).colorScheme.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No tasks available for this project. Please create a task first.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedTaskId,
      decoration: const InputDecoration(
        labelText: 'Task',
        border: OutlineInputBorder(),
      ),
      items: tasks.map((task) {
        return DropdownMenuItem<String>(
          value: task.id,
          child: Text(task.name ?? 'Unnamed Task'),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a task';
        }
        return null;
      },
    );
  }
}

class _DurationField extends StatelessWidget {
  final TextEditingController controller;

  const _DurationField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Duration (hours)',
        border: OutlineInputBorder(),
        hintText: 'e.g., 2.5',
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter duration';
        }
        final duration = double.tryParse(value);
        if (duration == null || duration <= 0) {
          return 'Please enter a valid duration';
        }
        return null;
      },
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({
    required this.selectedDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM d, yyyy').format(selectedDate)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;

  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Notes (optional)',
        border: OutlineInputBorder(),
        hintText: 'Add any additional notes...',
      ),
      maxLines: 3,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEditing;

  const _SaveButton({
    required this.onPressed,
    required this.isLoading,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(isEditing ? 'Update Time Entry' : 'Add Time Entry'),
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
          Icon(Icons.folder_open, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          const Text('No projects available'),
          const SizedBox(height: 8),
          const Text('Create a project first to add time entries'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
          ),
        ],
      ),
    );
  }
}
