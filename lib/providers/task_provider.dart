import 'package:flutter/foundation.dart';
import '../models/task/task.dart';
import '../services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _storageService.getAllTasks();
      _error = null;
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Task> addTask(String name, String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTask = await _storageService.addTask(name, projectId);
      _tasks.add(newTask);
      _error = null;
      return newTask;
    } catch (e) {
      _error = 'Failed to add task: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _storageService.updateTask(task);
      if (success) {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
        }
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Failed to update task: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _storageService.deleteTask(id);
      if (success) {
        _tasks.removeWhere((task) => task.id == id);
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Failed to delete task: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Task> getTasksByProjectId(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshTasks() async {
    await _loadTasks();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
