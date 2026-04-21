# SSH Client

A production-ready Flutter SSH client with interactive terminal, secure credential storage, and beautiful theming.

## Features

- **SSH Connections** — Password & private key authentication via `dartssh2`
- **Terminal Emulator** — Full PTY terminal using `xterm` widget
- **Multi-Session** — Multiple concurrent SSH sessions with tab switching
- **Background Keep-Alive** — Configurable heartbeat prevents idle disconnect
- **Mobile Keyboard** — Ctrl, Alt, Esc, Tab, arrows, F-keys, and common chars
- **Quick Connect** — One-time connections without saving
- **Connection Management** — Save, edit, duplicate, delete with confirmations
- **Search & Filter** — Find connections instantly as your list grows
- **Secure Storage** — Credentials encrypted with platform keychain/keystore
- **Theming** — Dark/light modes with `flex_color_scheme`, monospace terminal font
- **No Auth Required** — Pure client-side, anonymous, no backend
- **SFTP File Browser** — Browse, view, rename, delete remote files and create folders
- **SSH Tunneling** — Local and remote port forwarding with live tunnel management
- **Snippet Manager** — Save and quick-send frequently used commands
- **Connection Groups & Tags** — Organize connections with groups and tags, filter by group
- **Export/Import** — Backup and restore connections via JSON clipboard

## Tech Stack

| Layer | Technology |
|---|---|
| SSH Protocol | `dartssh2 ^2.17.1` |
| Terminal UI | `xterm ^4.0.0` |
| State | `flutter_riverpod ^2.5.0` |
| Theme | `flex_color_scheme ^8.4.0` + `google_fonts ^6.2.0` |
| Animations | `flutter_animate ^4.5.0` |
| Security | `flutter_secure_storage ^9.0.0` |
| Models | `freezed_annotation` + `json_annotation` |

## Typography

- **Titles & Headings** — Space Grotesk
- **Body Text** — Inter
- **Terminal** — JetBrains Mono

## Architecture

Clean Architecture with Riverpod — see [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) for full details.

```
lib/
├── core/          # Constants, theme, router, errors, utils
├── data/          # Models, providers, repositories, services
└── presentation/  # Screens, widgets, common components
```

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Platforms

iOS · Android · macOS · Web
