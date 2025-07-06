# Local Storage System for Time Tracker

This document describes the local storage implementation for the Flutter Time Tracker app, which handles projects, tasks, and time entries using `shared_preferences`.

## Overview

The storage system consists of:

- **StorageService**: Core service that handles all CRUD operations
- **Providers**: State management classes that integrate with the storage service
- **Models**: Data classes for Projects, Tasks, and Time Entries

## Architecture

```bash
lib/
├── services/
│   └── storage_service.dart          # Core storage operations
├── providers/
│   ├── project_provider.dart         # Project state management
│   ├── task_provider.dart            # Task state management
│   └── time_entry_provider.dart      # Time entry state management
├── models/
│   ├── project/
│   ├── task/
│   └── time_entry/
└── utils/
    └── storage_test.dart             # Testing utilities
```

## Dependencies

The following dependencies were added to `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.2.3  # Local storage
  uuid: ^4.5.1               # Unique ID generation
```

## StorageService

The `StorageService` class provides the following functionality:

### Project Operations

- `getAllProjects()` - Retrieve all projects
- `getProjectById(String id)` - Get a specific project
- `addProject(String name, {bool isDefault})` - Create a new project
- `updateProject(Project project)` - Update an existing project
- `deleteProject(String id)` - Delete a project (cascades to tasks and time entries)

### Task Operations

- `getAllTasks()` - Retrieve all tasks
- `getTasksByProjectId(String projectId)` - Get tasks for a specific project
- `getTaskById(String id)` - Get a specific task
- `addTask(String name, String projectId)` - Create a new task
- `updateTask(Task task)` - Update an existing task
- `deleteTask(String id)` - Delete a task (cascades to time entries)

### Time Entry Operations

- `getAllTimeEntries()` - Retrieve all time entries
- `getTimeEntriesByProjectId(String projectId)` - Get time entries for a project
- `getTimeEntriesByTaskId(String taskId)` - Get time entries for a task
- `getTimeEntriesByDate(String date)` - Get time entries for a specific date
- `getTimeEntryById(String id)` - Get a specific time entry
- `addTimeEntry({required projectId, taskId, date, duration, note})` - Create a new time entry
- `updateTimeEntry(TimeEntry timeEntry)` - Update an existing time entry
- `deleteTimeEntry(String id)` - Delete a time entry

### Utility Methods

- `clearAllData()` - Remove all stored data
- `getStorageStats()` - Get statistics about stored data

## Providers

Each provider extends `ChangeNotifier` and provides:

### ProjectProvider

- Manages project state
- Provides loading states and error handling
- Methods: `addProject()`, `updateProject()`, `deleteProject()`, `getProjectById()`, `getDefaultProject()`

### TaskProvider

- Manages task state
- Provides loading states and error handling
- Methods: `addTask()`, `updateTask()`, `deleteTask()`, `getTasksByProjectId()`, `getTaskById()`

### TimeEntryProvider

- Manages time entry state
- Provides loading states and error handling
- Methods: `addTimeEntry()`, `updateTimeEntry()`, `deleteTimeEntry()`, `getTimeEntriesByProjectId()`, `getTimeEntriesByTaskId()`, `getTimeEntriesByDate()`
- Utility methods: `getTotalDurationByDate()`, `getTotalDurationByProject()`, `getTotalDurationByTask()`

## Usage Examples

### Adding a Project

```dart
// Using the provider (recommended)
final projectProvider = context.read<ProjectProvider>();
final newProject = await projectProvider.addProject('My Project', isDefault: true);

// Direct storage service usage
final storageService = StorageService();
final newProject = await storageService.addProject('My Project', isDefault: true);
```

### Adding a Task

```dart
final taskProvider = context.read<TaskProvider>();
final newTask = await taskProvider.addTask('My Task', projectId);
```

### Adding a Time Entry

```dart
final timeEntryProvider = context.read<TimeEntryProvider>();
final newEntry = await timeEntryProvider.addTimeEntry(
  projectId: projectId,
  taskId: taskId,
  date: '2024-01-15',
  duration: 2.5,
  note: 'Worked on feature X',
);
```

### Retrieving Data

```dart
// Get all projects
final projects = context.watch<ProjectProvider>().projects;

// Get tasks for a specific project
final tasks = context.read<TaskProvider>().getTasksByProjectId(projectId);

// Get time entries for a date
final entries = context.read<TimeEntryProvider>().getTimeEntriesByDate('2024-01-15');
```

## Data Persistence

All data is stored using `shared_preferences` with the following keys:

- `projects` - List of project JSON strings
- `tasks` - List of task JSON strings
- `time_entries` - List of time entry JSON strings

Data is automatically serialized/deserialized using the generated JSON methods from `freezed` and `json_serializable`.

## Cascade Deletion

When you delete a project, all associated tasks and time entries are automatically deleted. When you delete a task, all associated time entries are automatically deleted.

## Testing

The `StorageTest` utility class provides methods to test the storage functionality:

```dart
// Run comprehensive storage tests
await StorageTest.runTest();

// Clear all test data
await StorageTest.clearTestData();
```

## Error Handling

All providers include error handling and loading states:

```dart
final provider = context.watch<ProjectProvider>();

if (provider.isLoading) {
  return CircularProgressIndicator();
}

if (provider.error != null) {
  return Text('Error: ${provider.error}');
}

// Use provider.projects safely
```

## Integration with UI

The storage system is integrated with the UI through providers in `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => ProjectProvider()),
    ChangeNotifierProvider(create: (context) => TaskProvider()),
    ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
  ],
  child: MaterialApp(...),
)
```

## Best Practices

1. **Use Providers**: Always use providers instead of directly accessing the storage service for better state management
2. **Handle Loading States**: Always check `isLoading` before displaying data
3. **Handle Errors**: Always check for errors and provide user feedback
4. **Refresh Data**: Call `refresh*()` methods when data might be stale
5. **Cascade Deletion**: Be aware that deleting projects/tasks will cascade to related data

## Future Enhancements

Potential improvements to consider:

- Add data export/import functionality
- Implement data backup to cloud storage
- Add data validation and constraints
- Implement data migration for schema changes
- Add data compression for large datasets
