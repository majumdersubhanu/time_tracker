import 'package:flutter/foundation.dart';
import '../models/time_entry/time_entry.dart';
import '../services/storage_service.dart';

class TimeEntryProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<TimeEntry> _timeEntries = [];
  bool _isLoading = false;
  String? _error;
  int _selectedIndex = 0;

  List<TimeEntry> get timeEntries => _timeEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
    notifyListeners();
  }

  TimeEntryProvider() {
    _loadTimeEntries();
  }

  Future<void> _loadTimeEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _timeEntries = await _storageService.getAllTimeEntries();
      _error = null;
    } catch (e) {
      _error = 'Failed to load time entries: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TimeEntry> addTimeEntry({
    required String projectId,
    required String taskId,
    required String date,
    required double duration,
    String? note,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTimeEntry = await _storageService.addTimeEntry(
        projectId: projectId,
        taskId: taskId,
        date: date,
        duration: duration,
        note: note,
      );
      _timeEntries.add(newTimeEntry);
      _error = null;
      return newTimeEntry;
    } catch (e) {
      _error = 'Failed to add time entry: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTimeEntry(TimeEntry timeEntry) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _storageService.updateTimeEntry(timeEntry);
      if (success) {
        final index = _timeEntries.indexWhere(
          (entry) => entry.id == timeEntry.id,
        );
        if (index != -1) {
          _timeEntries[index] = timeEntry;
        }
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Failed to update time entry: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTimeEntry(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _storageService.deleteTimeEntry(id);
      if (success) {
        _timeEntries.removeWhere((entry) => entry.id == id);
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Failed to delete time entry: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TimeEntry> getTimeEntriesByProjectId(String projectId) {
    return _timeEntries.where((entry) => entry.projectId == projectId).toList();
  }

  List<TimeEntry> getTimeEntriesByTaskId(String taskId) {
    return _timeEntries.where((entry) => entry.taskId == taskId).toList();
  }

  List<TimeEntry> getTimeEntriesByDate(String date) {
    return _timeEntries.where((entry) => entry.date == date).toList();
  }

  TimeEntry? getTimeEntryById(String id) {
    try {
      return _timeEntries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  double getTotalDurationByDate(String date) {
    return _timeEntries
        .where((entry) => entry.date == date)
        .fold(0.0, (sum, entry) => sum + (entry.duration ?? 0));
  }

  double getTotalDurationByProject(String projectId) {
    return _timeEntries
        .where((entry) => entry.projectId == projectId)
        .fold(0.0, (sum, entry) => sum + (entry.duration ?? 0));
  }

  double getTotalDurationByTask(String taskId) {
    return _timeEntries
        .where((entry) => entry.taskId == taskId)
        .fold(0.0, (sum, entry) => sum + (entry.duration ?? 0));
  }

  Future<void> refreshTimeEntries() async {
    await _loadTimeEntries();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
