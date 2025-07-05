import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';

class TimeEntryProvider extends ChangeNotifier {
  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  // LocalStorage instances for different data types
  late LocalStorage _timeEntriesStorage;
  late LocalStorage _projectsStorage;
  late LocalStorage _tasksStorage;

  List<TimeEntry> get timeEntries => _timeEntries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  // Get tasks for a specific project
  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  // Get project name by ID
  String getProjectName(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId).name;
    } catch (e) {
      return 'Unknown Project';
    }
  }

  // Get task name by ID
  String getTaskName(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId).name;
    } catch (e) {
      return 'Unknown Task';
    }
  }

  // Get time entries grouped by project
  Map<String, List<TimeEntry>> get timeEntriesByProject {
    Map<String, List<TimeEntry>> result = {};
    for (var entry in _timeEntries) {
      final projectName = getProjectName(entry.projectId);
      if (!result.containsKey(projectName)) {
        result[projectName] = [];
      }
      result[projectName]!.add(entry);
    }
    return result;
  }

  // Get total time for each project
  Map<String, Duration> get totalTimeByProject {
    Map<String, Duration> result = {};
    for (var entry in _timeEntries) {
      final projectName = getProjectName(entry.projectId);
      result[projectName] =
          (result[projectName] ?? Duration.zero) + entry.totalTime;
    }
    return result;
  }

  // Initialize the provider
  Future<void> initialize() async {
    // Initialize LocalStorage instances
    _timeEntriesStorage = LocalStorage('time_entries.json');
    _projectsStorage = LocalStorage('projects.json');
    _tasksStorage = LocalStorage('tasks.json');

    // Wait for storage to be ready
    await _timeEntriesStorage.ready;
    await _projectsStorage.ready;
    await _tasksStorage.ready;

    await _loadData();
  }

  // Load data from local storage
  Future<void> _loadData() async {
    try {
      // Load time entries
      final timeEntriesData =
          _timeEntriesStorage.getItem('timeEntries') as List<dynamic>?;
      if (timeEntriesData != null) {
        _timeEntries = timeEntriesData
            .map((json) => TimeEntry.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Load projects
      final projectsData =
          _projectsStorage.getItem('projects') as List<dynamic>?;
      if (projectsData != null) {
        _projects = projectsData
            .map((json) => Project.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Load tasks
      final tasksData = _tasksStorage.getItem('tasks') as List<dynamic>?;
      if (tasksData != null) {
        _tasks = tasksData
            .map((json) => Task.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // No default project - app starts empty

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }
  }

  // Save time entries to local storage
  Future<void> _saveTimeEntries() async {
    try {
      final jsonData = _timeEntries.map((entry) => entry.toJson()).toList();
      await _timeEntriesStorage.setItem('timeEntries', jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving time entries: $e');
      }
    }
  }

  // Save projects to local storage
  Future<void> _saveProjects() async {
    try {
      final jsonData = _projects.map((project) => project.toJson()).toList();
      await _projectsStorage.setItem('projects', jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving projects: $e');
      }
    }
  }

  // Save tasks to local storage
  Future<void> _saveTasks() async {
    try {
      final jsonData = _tasks.map((task) => task.toJson()).toList();
      await _tasksStorage.setItem('tasks', jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving tasks: $e');
      }
    }
  }

  // Add a new time entry
  Future<void> addTimeEntry(TimeEntry entry) async {
    _timeEntries.add(entry);
    await _saveTimeEntries();
    notifyListeners();
  }

  // Delete a time entry
  Future<void> deleteTimeEntry(String id) async {
    _timeEntries.removeWhere((entry) => entry.id == id);
    await _saveTimeEntries();
    notifyListeners();
  }

  // Add a new project
  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _saveProjects();
    notifyListeners();
  }

  // Delete a project
  Future<void> deleteProject(String id) async {
    _projects.removeWhere((project) => project.id == id);
    // Remove tasks associated with this project
    _tasks.removeWhere((task) => task.projectId == id);
    // Remove time entries associated with this project
    _timeEntries.removeWhere((entry) => entry.projectId == id);
    await _saveProjects();
    await _saveTasks();
    await _saveTimeEntries();
    notifyListeners();
  }

  // Update a project
  Future<void> updateProject(Project project) async {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      await _saveProjects();
      notifyListeners();
    }
  }

  // Get project by name
  Project? getProjectByName(String name) {
    try {
      return _projects.firstWhere((project) => project.name == name);
    } catch (e) {
      return null;
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    // Remove time entries associated with this task
    _timeEntries.removeWhere((entry) => entry.taskId == id);
    await _saveTasks();
    await _saveTimeEntries();
    notifyListeners();
  }

  // Update a task
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _saveTasks();
      notifyListeners();
    }
  }

  // Get task by name for a specific project
  Task? getTaskByName(String projectId, String name) {
    try {
      return _tasks.firstWhere(
        (task) => task.projectId == projectId && task.name == name,
      );
    } catch (e) {
      return null;
    }
  }
}
