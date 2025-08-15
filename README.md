# Color Connect 🎨

A challenging puzzle game built with Flutter and Flame engine where players connect matching colors to solve increasingly difficult levels.

## 🎯 Game Overview

Color Connect is a brain-teasing puzzle game that challenges players to connect all matching colors on a grid without crossing paths. Each level presents a unique challenge with different grid sizes, color combinations, and difficulty levels.

### Game Features
- **100+ Challenging Levels**: From simple 5x5 grids to complex 7x7 puzzles
- **Multiple Colors**: 3-5 different colors per level
- **Progressive Difficulty**: Levels unlock as you complete previous ones
- **Star Rating System**: Earn 1-3 stars based on performance
- **Hint System**: Get help when you're stuck
- **Undo/Reset**: Correct mistakes and try different approaches
- **Beautiful UI**: Modern Material Design with smooth animations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/color-connect.git
   cd color-connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS (requires macOS):**
```bash
flutter build ios --release
```

## 🏗️ Project Structure

```
lib/
├── core/                    # Core app configuration
│   ├── app.dart           # Main app entry point
│   └── theme/             # App themes and styling
├── features/               # Feature-based modules
│   ├── home/              # Home screen and main menu
│   ├── level_select/      # Level selection screen
│   ├── game/              # Game logic and UI
│   └── settings/          # Settings and preferences
└── shared/                # Shared utilities and components

assets/
├── images/                # Game images and icons
├── audio/                 # Sound effects and music
├── levels/                # Level data files
└── fonts/                 # Custom fonts

test/                      # Unit and widget tests
```

## 🎮 Game Mechanics

### Core Rules
1. **Connect Colors**: Draw paths between matching color pairs
2. **No Crossings**: Paths cannot intersect or overlap
3. **Fill Grid**: Every cell must be filled with a path
4. **Complete All**: All color pairs must be connected

### Level Progression
- **Levels 1-10**: 5x5 grids with 3 colors
- **Levels 11-20**: 6x6 grids with 4 colors  
- **Levels 21+**: 7x7 grids with 5 colors

### Scoring System
- **3 Stars**: Complete level with minimal moves
- **2 Stars**: Complete level with moderate moves
- **1 Star**: Complete level with many moves

## 🛠️ Development

### Architecture
The project follows a clean architecture pattern with:
- **Presentation Layer**: UI components and pages
- **Domain Layer**: Business logic and entities
- **Data Layer**: Repositories and data sources

### State Management
- **Riverpod**: For state management and dependency injection
- **Hive**: For local data persistence
- **Flame**: For game engine and rendering

### Key Dependencies
```yaml
dependencies:
  flutter: sdk
  flame: ^1.16.0              # Game engine
  flutter_riverpod: ^2.4.9    # State management
  hive: ^2.2.3                # Local storage
  shared_preferences: ^2.2.2  # Settings storage
```

## 🧪 Testing

Run tests with:
```bash
# Unit tests
flutter test

# Coverage report
flutter test --coverage
```

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Web**: Modern browsers (Chrome, Firefox, Safari, Edge)

## 🎨 Customization

### Themes
The app supports both light and dark themes with customizable:
- Color schemes
- Typography
- Component styles

### Accessibility
- Colorblind-friendly color schemes
- High contrast options
- Screen reader support

## 📈 Roadmap

### Phase 1: Core Foundation ✅
- [x] Project setup and structure
- [x] Basic UI screens
- [x] Navigation system
- [x] Theme configuration

### Phase 2: Game Engine 🚧
- [ ] Flame engine integration
- [ ] Grid rendering system
- [ ] Touch gesture handling
- [ ] Game logic implementation

### Phase 3: Game Features 📋
- [ ] Level system
- [ ] Progress tracking
- [ ] Hint system
- [ ] Tutorial

### Phase 4: Polish & Testing 📋
- [ ] Animations and effects
- [ ] Sound integration
- [ ] Performance optimization
- [ ] Comprehensive testing

### Phase 5: Monetization 📋
- [ ] Ad integration
- [ ] In-app purchases
- [ ] Analytics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices
- Write comprehensive tests
- Use meaningful commit messages
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Flame engine developers
- Riverpod for state management
- All contributors and testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/color-connect/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/color-connect/discussions)
- **Email**: your.email@example.com

---

**Made with ❤️ using Flutter & Flame**
