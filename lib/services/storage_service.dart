import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/project/project.dart';
import '../models/task/task.dart';
import '../models/time_entry/time_entry.dart';

class StorageService {
  static const String _projectsKey = 'projects';
  static const String _tasksKey = 'tasks';
  static const String _timeEntriesKey = 'time_entries';

  final Uuid _uuid = const Uuid();

  // Project operations
  Future<List<Project>> getAllProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getStringList(_projectsKey) ?? [];

    return projectsJson
        .map((json) => Project.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<Project?> getProjectById(String id) async {
    final projects = await getAllProjects();
    try {
      return projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Project> addProject(String name, {bool isDefault = false}) async {
    final projects = await getAllProjects();

    // If this project is being set as default, remove default from all other projects
    if (isDefault) {
      for (var project in projects) {
        project = project.copyWith(isDefault: false);
      }
    }

    final newProject = Project(
      id: _uuid.v4(),
      name: name,
      isDefault: isDefault,
    );

    projects.add(newProject);
    await _saveProjects(projects);

    return newProject;
  }

  Future<bool> updateProject(Project project) async {
    final projects = await getAllProjects();
    final index = projects.indexWhere((p) => p.id == project.id);

    if (index != -1) {
      // If this project is being set as default, remove default from all other projects
      if (project.isDefault == true) {
        for (int i = 0; i < projects.length; i++) {
          if (i != index) {
            projects[i] = projects[i].copyWith(isDefault: false);
          }
        }
      }

      projects[index] = project;
      await _saveProjects(projects);
      return true;
    }
    return false;
  }

  Future<bool> deleteProject(String id) async {
    final projects = await getAllProjects();
    final initialLength = projects.length;

    projects.removeWhere((project) => project.id == id);

    if (projects.length < initialLength) {
      await _saveProjects(projects);

      // Also delete associated tasks and time entries
      await _deleteTasksByProjectId(id);
      await _deleteTimeEntriesByProjectId(id);

      return true;
    }
    return false;
  }

  Future<void> _saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = projects
        .map((project) => jsonEncode(project.toJson()))
        .toList();
    await prefs.setStringList(_projectsKey, projectsJson);
  }

  // Task operations
  Future<List<Task>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];

    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  Future<List<Task>> getTasksByProjectId(String projectId) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final tasks = await getAllTasks();
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Task> addTask(String name, String projectId) async {
    final tasks = await getAllTasks();

    final newTask = Task(id: _uuid.v4(), name: name, projectId: projectId);

    tasks.add(newTask);
    await _saveTasks(tasks);

    return newTask;
  }

  Future<bool> updateTask(Task task) async {
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);

    if (index != -1) {
      tasks[index] = task;
      await _saveTasks(tasks);
      return true;
    }
    return false;
  }

  Future<bool> deleteTask(String id) async {
    final tasks = await getAllTasks();
    final initialLength = tasks.length;

    tasks.removeWhere((task) => task.id == id);

    if (tasks.length < initialLength) {
      await _saveTasks(tasks);

      // Also delete associated time entries
      await _deleteTimeEntriesByTaskId(id);

      return true;
    }
    return false;
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  Future<void> _deleteTasksByProjectId(String projectId) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((task) => task.projectId == projectId);
    await _saveTasks(tasks);
  }

  // Time Entry operations
  Future<List<TimeEntry>> getAllTimeEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final timeEntriesJson = prefs.getStringList(_timeEntriesKey) ?? [];

    return timeEntriesJson
        .map((json) => TimeEntry.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<List<TimeEntry>> getTimeEntriesByProjectId(String projectId) async {
    final timeEntries = await getAllTimeEntries();
    return timeEntries.where((entry) => entry.projectId == projectId).toList();
  }

  Future<List<TimeEntry>> getTimeEntriesByTaskId(String taskId) async {
    final timeEntries = await getAllTimeEntries();
    return timeEntries.where((entry) => entry.taskId == taskId).toList();
  }

  Future<List<TimeEntry>> getTimeEntriesByDate(String date) async {
    final timeEntries = await getAllTimeEntries();
    return timeEntries.where((entry) => entry.date == date).toList();
  }

  Future<TimeEntry?> getTimeEntryById(String id) async {
    final timeEntries = await getAllTimeEntries();
    try {
      return timeEntries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<TimeEntry> addTimeEntry({
    required String projectId,
    required String taskId,
    required String date,
    required double duration,
    String? note,
  }) async {
    final timeEntries = await getAllTimeEntries();

    final newTimeEntry = TimeEntry(
      id: _uuid.v4(),
      projectId: projectId,
      taskId: taskId,
      date: date,
      duration: duration,
      note: note,
    );

    timeEntries.add(newTimeEntry);
    await _saveTimeEntries(timeEntries);

    return newTimeEntry;
  }

  Future<bool> updateTimeEntry(TimeEntry timeEntry) async {
    final timeEntries = await getAllTimeEntries();
    final index = timeEntries.indexWhere((entry) => entry.id == timeEntry.id);

    if (index != -1) {
      timeEntries[index] = timeEntry;
      await _saveTimeEntries(timeEntries);
      return true;
    }
    return false;
  }

  Future<bool> deleteTimeEntry(String id) async {
    final timeEntries = await getAllTimeEntries();
    final initialLength = timeEntries.length;

    timeEntries.removeWhere((entry) => entry.id == id);

    if (timeEntries.length < initialLength) {
      await _saveTimeEntries(timeEntries);
      return true;
    }
    return false;
  }

  Future<void> _saveTimeEntries(List<TimeEntry> timeEntries) async {
    final prefs = await SharedPreferences.getInstance();
    final timeEntriesJson = timeEntries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList(_timeEntriesKey, timeEntriesJson);
  }

  Future<void> _deleteTimeEntriesByProjectId(String projectId) async {
    final timeEntries = await getAllTimeEntries();
    timeEntries.removeWhere((entry) => entry.projectId == projectId);
    await _saveTimeEntries(timeEntries);
  }

  Future<void> _deleteTimeEntriesByTaskId(String taskId) async {
    final timeEntries = await getAllTimeEntries();
    timeEntries.removeWhere((entry) => entry.taskId == taskId);
    await _saveTimeEntries(timeEntries);
  }

  // Utility methods
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_projectsKey);
    await prefs.remove(_tasksKey);
    await prefs.remove(_timeEntriesKey);
  }

  Future<Map<String, dynamic>> getStorageStats() async {
    final projects = await getAllProjects();
    final tasks = await getAllTasks();
    final timeEntries = await getAllTimeEntries();

    return {
      'projects_count': projects.length,
      'tasks_count': tasks.length,
      'time_entries_count': timeEntries.length,
      'total_duration': timeEntries.fold(
        0.0,
        (sum, entry) => sum + (entry.duration ?? 0),
      ),
    };
  }
}
