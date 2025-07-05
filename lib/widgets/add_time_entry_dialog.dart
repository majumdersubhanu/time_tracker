import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/time_entry_provider.dart';
import '../models/time_entry.dart';
import '../screens/project_task_management_screen.dart';

class AddTimeEntryDialog extends StatefulWidget {
  const AddTimeEntryDialog({super.key});

  @override
  State<AddTimeEntryDialog> createState() => _AddTimeEntryDialogState();
}

class _AddTimeEntryDialogState extends State<AddTimeEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String _selectedProjectId = '';
  String _selectedTaskId = '';
  DateTime _selectedDate = DateTime.now();
  int _hours = 0;
  int _minutes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TimeEntryProvider>(context, listen: false);
      if (provider.projects.isNotEmpty) {
        setState(() {
          _selectedProjectId = provider.projects.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.projects.isEmpty) {
          return AlertDialog(
            title: const Text('No Projects Available'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'You need to create a project first before adding time entries.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProjectTaskManagementScreen(),
                    ),
                  );
                },
                child: const Text('Create Project'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Add Time Entry'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project Selection
                    DropdownButtonFormField<String>(
                      value: _selectedProjectId.isNotEmpty
                          ? _selectedProjectId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Project',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: provider.projects.map((project) {
                        return DropdownMenuItem(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value!;
                          _selectedTaskId =
                              ''; // Reset task selection when project changes
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a project';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Task Selection
                    DropdownButtonFormField<String>(
                      value: _selectedTaskId.isNotEmpty
                          ? _selectedTaskId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Task',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.task),
                      ),
                      items: provider
                          .getTasksForProject(_selectedProjectId)
                          .map((task) {
                            return DropdownMenuItem(
                              value: task.id,
                              child: Text(task.name),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTaskId = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a task';
                        }
                        return null;
                      },
                    ),
                    if (provider
                            .getTasksForProject(_selectedProjectId)
                            .isEmpty &&
                        _selectedProjectId.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'No tasks available for this project. Create tasks first.',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Date Selection
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time Input
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _hours,
                            decoration: const InputDecoration(
                              labelText: 'Hours',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            items: List.generate(25, (index) {
                              return DropdownMenuItem(
                                value: index,
                                child: Text('$index'),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _hours = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _minutes,
                            decoration: const InputDecoration(
                              labelText: 'Minutes',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(60, (index) {
                              return DropdownMenuItem(
                                value: index,
                                child: Text('$index'),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _minutes = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes Input
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _submitForm(provider),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm(TimeEntryProvider provider) async {
    if (_formKey.currentState!.validate()) {
      if (_hours == 0 && _minutes == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a time duration'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final timeEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: _selectedProjectId,
        taskId: _selectedTaskId,
        totalTime: Duration(hours: _hours, minutes: _minutes),
        date: _selectedDate,
        notes: _notesController.text,
      );

      await provider.addTimeEntry(timeEntry);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time entry added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
