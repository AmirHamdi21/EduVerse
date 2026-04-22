<div align="center">

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/BLoC-purple?style=for-the-badge" />
<img src="https://img.shields.io/badge/AI--Powered-FF6B35?style=for-the-badge" />

# 🎓 EduVerse

**A comprehensive AI-powered Learning Management System built with Flutter**

*One platform. Every role. Smarter education.*

</div>

---

## 📖 Overview

EduVerse is a full-featured, cross-platform **Learning Management System (LMS)** developed in Flutter, designed to unify the academic experience for every stakeholder in an educational institution. From students consuming course content and leveraging AI study tools, to instructors managing labs and grading, to Teaching Assistants monitoring student performance, to administrators overseeing the entire platform — EduVerse brings them all together in a single cohesive application.

What sets EduVerse apart is its deep integration of **AI-driven features** across all user roles: intelligent tutoring chatbots, AI-generated notes and summaries, smart study schedules, AI-assisted grading, face-recognition attendance, and institutional analytics — all built on a clean, scalable BLoC/Cubit architecture.

---

## ✨ Key Features

### 🤖 AI-Powered Learning Tools
- **AI Chat Assistant** — Context-aware tutoring chatbot for students
- **AI Notes Generator** — Automatically generates structured notes from course materials
- **Content Summarizer** — Summarizes lectures, documents, and readings on demand
- **Smart Study Planner** — AI-driven personalized study schedules and topic review cards
- **AI Quiz Generator** — Generates quizzes based on course content
- **AI Flashcards** — Auto-generated flashcard sets for active recall practice
- **Voice-to-Text Transcription** — Records and transcribes lectures with waveform visualization

### 👨‍🎓 Student Experience
- Personalized dashboard with performance stats, to-do lists, and quick-access shortcuts
- Full course browsing, filtering, enrollment, and detailed course content viewer
- Assignment submission with late-penalty tracking and submission history
- Lab participation and submission management
- Grades view with GPA tracking, grade analysis, and transcript export (PDF)
- Attendance tracking with per-course breakdowns
- Real-time chat and discussion threads
- Gamification system with achievements, leaderboards, and rewards
- Personal file storage with cloud sync
- Schedule and calendar management
- Granular notification and swipe-action settings

### 👨‍🏫 Instructor Portal
- Dashboard with course statistics, recent activity, and AI teaching insights
- Full course and material management with bundle support
- Lab creation and detailed lab management
- Assignment creation, submission review, and grading center
- Attendance management (with AI processing support)
- Roster management and student search
- Reports & analytics screen
- Calendar and office hours management
- AI Teaching assistant for content planning
- Announcement management

### 🧑‍💼 Teaching Assistant (TA) Portal
- Dedicated TA dashboard with assigned courses and task center
- AI-powered grading assistance with batch evaluation support
- Student performance tracking with at-risk detection and AI insights
- Lab oversight — attendance, submissions, and resource management
- Student inbox with AI reply assistant
- Analytics with session comparison, deadline detection, and performance charts
- Assignment submission review and grading center

### 🛡️ Admin Control Panel
- Full user management (create, manage roles, assign staff)
- Course lifecycle management with enrollment periods
- Department management with health mapping and statistics
- System-wide attendance analytics
- Comprehensive settings: branding, email, SMS, push notifications, payment gateways, cloud storage, video conferencing, webhooks, 2FA policies, password policies, and more
- Audit logs, compliance tracking, and security management
- Backup center with scheduling, history, and export options
- AI Insights dashboard with recommendations and quick actions
- Campus events and office hours management

### 🔧 IT Admin Portal
- Server and database management
- System health monitoring and performance reports
- Error logs, security logs, and alert management
- Cloud services and integration management
- AI model settings and API management

### 🌐 Platform-Wide Capabilities
- **Multi-role architecture** — Student, Instructor, TA, Admin, IT Admin
- **Bilingual support** — Full Arabic and English localization (ARB-based)
- **Theme system** — Light/dark mode with custom appearance settings
- **Real-time messaging** — WebSocket-powered chat with swipe-action customization
- **Responsive UI** — Adaptive layouts for mobile and tablet
- **Offline resilience** — Connectivity monitoring and retry logic

---

## 🏗️ Architecture

EduVerse follows a **clean, feature-driven architecture** with a strict separation of concerns.

```
lib/
├── bloc/               # Global BLoC/Cubit state management (per feature)
├── common/             # Shared utilities, services, helpers
├── config/             # App router and theme configuration
├── features/           # Self-contained feature modules (bloc + screens)
├── generated_l10n/     # Auto-generated localization classes
├── l10n/               # ARB localization source files (en, ar)
├── models/             # Data models organized by domain
├── screens/            # Screen-level UI organized by role
│   ├── admin/
│   ├── instructor/
│   ├── student/
│   ├── ta/
│   ├── it_admin/
│   ├── auth/
│   ├── shared/
│   └── onBoarding/
├── services/           # API clients, socket services, storage, auth
├── utils/              # Utility functions (file validation, penalty calc, etc.)
├── widgets/            # Reusable UI components organized by role and feature
└── main.dart
```

### State Management

EduVerse uses the **BLoC pattern** (via `flutter_bloc`) throughout the application. Complex, event-driven flows use full `Bloc` classes with explicit events, while simpler state containers use `Cubit`. Each feature area owns its own bloc/cubit isolated within the `bloc/` directory.

### Services Layer

All backend communication is abstracted behind a dedicated `services/` layer:
- `core_api_client.dart` — Central HTTP client with interceptors
- `auth_interceptor.dart` — Token injection and session expiry handling
- `chat_socket_service.dart` — Real-time WebSocket communication
- `storage_service.dart` — Local persistence (tokens, preferences)
- `connectivity_service.dart` — Network state monitoring
- Domain-specific services for courses, grades, attendance, labs, notifications, and more

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (≥ 3.x recommended)
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode for platform-specific builds
- A running instance of the EduVerse backend API

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/eduverse.git
cd eduverse

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run the app
flutter run
```

### Environment Configuration

Configure your API base URL and any environment-specific settings in:

```
lib/services/api_service.dart
```

> **Note:** If the project uses `.env` files or a config package, update the appropriate config file before running.

---

## 📱 Supported Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅ Supported |
| iOS      | ✅ Supported |
| Web      | 🔄 In Progress |
| Desktop  | 🔄 Planned |

---

## 🗂️ Project Structure — Key Modules

| Module | Description |
|--------|-------------|
| `bloc/ai_chat` | AI tutoring chatbot state management |
| `bloc/ai_notes` | AI notes generation flow |
| `bloc/smart_study` | Smart study planner logic |
| `bloc/gamification` | Points, badges, and leaderboard state |
| `bloc/attendance` | Multi-role attendance (student, instructor, TA, admin) |
| `bloc/voice_to_text` | Voice recording and transcription |
| `bloc/admin_course_management` | Course wizard, enrollment, and listing for admins |
| `models/core` | Shared enums and foundational domain models |
| `services/api` | Complete REST API service layer |
| `widgets/admin` | Admin-specific UI component library |
| `widgets/student` | Student-specific UI component library |
| `widgets/instructor` | Instructor-specific UI component library |
| `widgets/ta` | TA-specific UI component library |

---

## 🌍 Localization

EduVerse supports **English** and **Arabic** out of the box, using Flutter's official `gen-l10n` tool.

- Source files: `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
- Generated classes: `lib/generated_l10n/`
- Language switching is handled at runtime via `bloc/language/language_cubit.dart`

To add a new language, create a new `.arb` file and run `flutter gen-l10n`.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to your branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please adhere to the existing BLoC architecture patterns and ensure new features are accompanied by appropriate state management classes.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

Built with ❤️ using Flutter

</div>
