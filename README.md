# Time Tracker App

A Flutter-based time tracking application that helps users monitor time spent on different tasks and projects. The app uses local storage to save data, ensuring entries aren't lost when the app is closed and reopened.

## 📱 Features

### Core Features

- ✅ **View Time Entries**: Browse all time entries in a clean, organized list
- ✅ **Add Time Entries**: Create detailed time entries with project, task, duration, date, and notes
- ✅ **Local Storage**: All data is saved locally and persists across app sessions
- ✅ **Group by Projects**: View time entries organized by projects for better insights
- ✅ **Delete Entries**: Remove incorrect or unnecessary time entries
- ✅ **Manage Projects & Tasks**: Full CRUD operations for projects and tasks

### Additional Features

- 🎯 **Default Projects**: Set a default project for quick access
- 📊 **Statistics**: View total time spent on projects and tasks
- 📅 **Date Selection**: Easy date picker for time entries
- 🔄 **Real-time Updates**: UI updates immediately when data changes
- 🎨 **Material Design 3**: Modern, intuitive user interface
- 📱 **Responsive Design**: Works on various screen sizes

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or physical device

### Installation

1. **Clone the repository**

   ```bash
   git clone http://github.com/majumdersubhanu/time_tracker
   cd time_tracker
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate model files**

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**

   ```bash
   flutter run
   ```

## 📖 How to Use

### First Time Setup

1. **Create a Project**
   - Open the app
   - Navigate to the drawer menu (hamburger icon)
   - Tap "Projects"
   - Use the "+" button to add your first project
   - Optionally set it as the default project

2. **Add Tasks**
   - In the drawer menu, tap "Tasks"
   - Use the "+" button to add tasks to your projects
   - Tasks are organized by their parent projects

3. **Start Tracking Time**
   - Use the "+" button on the home screen to add time entries
   - Select a project and task
   - Enter the duration in hours
   - Choose a date
   - Add optional notes
   - Save your entry

### Daily Usage

- **View Entries**: Use the tabs on the home screen to view all entries or group by projects
- **Add Entries**: Tap the floating action button to quickly add new time entries
- **Manage Data**: Use the drawer menu to manage projects and tasks
- **Delete Entries**: Use the delete button on any entry to remove it

## 🏗️ Project Structure

```bash
lib/
├── main.dart                    # App entry point with providers
├── models/                      # Data models
│   ├── project/
│   │   ├── project.dart
│   │   ├── project.freezed.dart
│   │   └── project.g.dart
│   ├── task/
│   │   ├── task.dart
│   │   ├── task.freezed.dart
│   │   └── task.g.dart
│   └── time_entry/
│       ├── time_entry.dart
│       ├── time_entry.freezed.dart
│       └── time_entry.g.dart
├── providers/                   # State management
│   ├── project_provider.dart
│   ├── task_provider.dart
│   └── time_entry_provider.dart
├── screens/                     # UI screens
│   ├── home_screen.dart
│   ├── add_time_entry_screen.dart
│   ├── manage_projects_screen.dart
│   └── manage_tasks_screen.dart
├── services/                    # Business logic
│   └── storage_service.dart
└── utils/                       # Utilities
    └── storage_test.dart
```

## 🛠️ Technical Details

### Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  json_annotation: ^4.9.0
  freezed_annotation:
  provider: ^6.1.5
  shared_preferences: ^2.2.3  # Local storage
  uuid: ^4.5.1               # Unique ID generation
  intl: ^0.19.0              # Date formatting
```

### Architecture

- **State Management**: Provider pattern for reactive UI updates
- **Local Storage**: SharedPreferences for persistent data storage
- **Data Models**: Freezed for immutability and JSON serialization
- **UI Framework**: Material Design 3 components

### Key Components

#### Storage Service

- Handles all CRUD operations for projects, tasks, and time entries
- Uses SharedPreferences for local storage
- Implements cascade deletion (deleting project deletes related tasks and entries)

#### Providers

- **ProjectProvider**: Manages project state and operations
- **TaskProvider**: Manages task state and operations
- **TimeEntryProvider**: Manages time entry state and operations

#### Screens

- **HomeScreen**: Main dashboard with tabs for viewing entries
- **AddTimeEntryScreen**: Form for creating new time entries
- **ManageProjectsScreen**: Project management interface
- **ManageTasksScreen**: Task management interface

## 🧪 Testing

The app includes a comprehensive testing utility:

```dart
// Run storage tests
await StorageTest.runTest();

// Clear all test data
await StorageTest.clearTestData();
```

Access the test functionality through the drawer menu.

## 📱 Screenshots

### Home Screen

- Two-tab interface showing all entries and grouped by projects
- Floating action button for adding new entries
- Drawer menu for navigation

### Add Time Entry

- Comprehensive form with project/task selection
- Duration input with validation
- Date picker and notes field

### Manage Projects

- List of all projects with statistics
- Add, edit, and delete functionality
- Default project setting

### Manage Tasks

- Tasks organized by projects
- Add, edit, and delete functionality
- Time entry statistics per task

## 🔧 Development

### Code Generation

After making changes to models, regenerate the freezed files:

```bash
flutter packages pub run build_runner build
```

### Adding New Features

1. **Models**: Add new data models in the `models/` directory
2. **Services**: Add business logic in the `services/` directory
3. **Providers**: Add state management in the `providers/` directory
4. **Screens**: Add UI screens in the `screens/` directory

### Code Style

The project follows Flutter's recommended code style:

- Use meaningful variable and function names
- Add comments for complex logic
- Follow the existing project structure
- Use proper error handling

## 🐛 Troubleshooting

### Common Issues

1. **Build Errors**

   ```bash
   flutter clean
   flutter pub get
   flutter packages pub run build_runner build
   ```

2. **Storage Issues**
   - Use the "Clear All Data" option in the drawer menu
   - Restart the app

3. **UI Not Updating**
   - Ensure you're using `Consumer` widgets for reactive updates
   - Check that providers are properly registered in `main.dart`

### Debug Mode

Enable debug mode for additional logging:

```bash
flutter run --debug
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support and questions:

- Create an issue in the repository
- Check the documentation in the `docs/` folder
- Review the code comments for implementation details

## 🎯 Roadmap

Future enhancements planned:

- [ ] Data export functionality
- [ ] Cloud synchronization
- [ ] Advanced reporting and analytics
- [ ] Time tracking timer
- [ ] Multiple user support
- [ ] Dark mode theme
- [ ] Widget support for quick access

---

Built with ❤️ using Flutter by Subhanu Majumder
