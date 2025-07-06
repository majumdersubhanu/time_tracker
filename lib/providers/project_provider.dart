import 'package:flutter/foundation.dart';
import '../models/project/project.dart';
import '../services/storage_service.dart';

class ProjectProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProjectProvider() {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _storageService.getAllProjects();
      _error = null;
    } catch (e) {
      _error = 'Failed to load projects: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Project> addProject(String name, {bool isDefault = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProject = await _storageService.addProject(
        name,
        isDefault: isDefault,
      );
      _projects.add(newProject);
      _error = null;
      return newProject;
    } catch (e) {
      _error = 'Failed to add project: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProject(Project project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _storageService.updateProject(project);
      if (success) {
        final index = _projects.indexWhere((p) => p.id == project.id);
        if (index != -1) {
          _projects[index] = project;
        }
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Failed to update project: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProject(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _storageService.deleteProject(id);
      if (success) {
        _projects.removeWhere((project) => project.id == id);
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Failed to delete project: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  Project? getDefaultProject() {
    try {
      return _projects.firstWhere((project) => project.isDefault == true);
    } catch (e) {
      return _projects.isNotEmpty ? _projects.first : null;
    }
  }

  Future<void> refreshProjects() async {
    await _loadProjects();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
