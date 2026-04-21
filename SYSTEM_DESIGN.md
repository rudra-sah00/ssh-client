# SSH Client — System Design

## 1. Overview

A production-ready Flutter SSH client supporting password & key-based authentication, interactive terminal sessions, and secure credential storage. Targets iOS, Android, macOS, and web.

## 2. Architecture

**Pattern:** Feature-first Clean Architecture + Riverpod for state management.

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  Screens → Widgets → Riverpod UI   │
├─────────────────────────────────────┤
│          Provider Layer             │
│  Riverpod Providers (state logic)   │
├─────────────────────────────────────┤
│            Data Layer               │
│  Services → Repositories → Models   │
├─────────────────────────────────────┤
│          External Packages          │
│  dartssh2 · xterm · secure_storage  │
└─────────────────────────────────────┘
```

## 3. Core Modules

### 3.1 SSH Module (`dartssh2`)
- Connect/disconnect lifecycle
- Password & private key authentication
- Interactive shell sessions (PTY)
- Terminal resize support
- SFTP (future scope)

### 3.2 Terminal Module (`xterm`)
- Full terminal emulation widget
- Bidirectional data binding with SSH shell
- Custom font (JetBrains Mono via `google_fonts`)
- Copy/paste support

### 3.3 Connection Management
- CRUD operations for saved connections
- Credentials encrypted via `flutter_secure_storage`
- Connection model with Freezed immutability + JSON serialization

### 3.4 State Management (`riverpod`)
- `connectionListProvider` — saved connections
- `sshSessionProvider` — active SSH session state
- `terminalProvider` — terminal instance per session
- `settingsProvider` — app preferences

### 3.5 Theming (`flex_color_scheme` + `google_fonts`)
- Light/dark mode with FlexColorScheme
- Inter for UI, JetBrains Mono for terminal
- Animated transitions via `flutter_animate`

### 3.6 Multi-Session Manager
- `SessionManager` holds all active `SshSession` instances in memory
- Sessions survive navigation (global Riverpod provider)
- Each session owns its own `SshServiceImpl` + `Terminal` instance
- Tab switcher in terminal AppBar to jump between active sessions
- Close individual sessions or all at once

### 3.7 Background Keep-Alive
- Per-session periodic timer sends null-byte to prevent idle disconnect
- Configurable interval via `SettingsModel.keepAliveInterval` (default 30s)
- Toggle on/off via `SettingsModel.keepAlive`
- Timer auto-cancels on session close

### 3.8 Mobile Terminal Control Bar
- Horizontal scrollable bar below terminal with special keys
- **Modifier toggles:** Ctrl, Alt (sticky — tap once, next key is modified)
- **Navigation:** Arrow keys (↑↓←→), Home, End, PgUp, PgDn
- **Special keys:** Esc, Tab, Del, Ins, F1–F5
- **Common chars:** `|`, `/`, `-`, `~`
- Ctrl+key sends proper ASCII control character (e.g. Ctrl+C = 0x03)
- Alt+key sends ESC prefix sequence

## 4. Data Flow

```
User taps Connect
  → connectionProvider reads ConnectionModel
  → sshServiceProvider.connect(model)
  → dartssh2 opens SSH session + PTY shell
  → shell I/O stream ↔ xterm Terminal widget
  → UI renders live terminal output
```

## 5. Security

| Concern | Solution |
|---|---|
| Credential storage | `flutter_secure_storage` (Keychain/Keystore) |
| Private keys | Stored encrypted, never in plaintext |
| Memory | Credentials cleared on disconnect |
| Transport | SSH protocol (encrypted by default) |

## 6. Folder Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── errors/          # Custom exceptions
│   ├── extensions/      # Dart extensions
│   ├── router/          # Navigation routes
│   ├── theme/           # FlexColorScheme config
│   └── utils/           # Helpers
├── data/
│   ├── models/          # Freezed data classes
│   ├── providers/       # Riverpod providers
│   ├── repositories/    # Data access layer
│   └── services/        # SSH, storage, terminal
└── presentation/
    ├── screens/         # Full-page views
    ├── widgets/         # Reusable components
    └── common/          # Shared UI elements
```

## 7. Key Dependencies

| Package | Purpose |
|---|---|
| `dartssh2` | SSH2 protocol client |
| `xterm` | Terminal emulator widget |
| `flutter_riverpod` | State management |
| `flex_color_scheme` | Theming |
| `google_fonts` | Typography |
| `flutter_animate` | UI animations |
| `flutter_secure_storage` | Encrypted storage |
| `freezed_annotation` | Immutable models |
| `json_annotation` | JSON serialization |

## 8. UX Features

### 8.1 Active Session Indicator
- Connection tiles show green badge with active session count
- Popup menu offers "Resume Session" for connections with active sessions

### 8.2 Quick Connect
- Lightning bolt icon in AppBar opens one-time connect dialog
- Host, port, username, password — connects without saving to storage

### 8.3 Connection Duplicate
- "Duplicate" in popup menu clones connection with "(copy)" suffix
- New ID generated, immediately saved to storage

### 8.4 Confirm Dialogs
- Delete connection: confirmation with red "Delete" button
- Disconnect session: confirmation with red "Disconnect" button

### 8.5 Snackbar Feedback
- "Connected to X" on successful SSH connection
- "Disconnected from X" on session close
- "Deleted X" on connection removal
- "Duplicated X" on connection clone
- Red snackbar on connection failure

### 8.6 Search & Filter
- Search bar appears when >3 saved connections
- Filters by connection name, host, and tags in real-time
- Group filter chips for quick category switching

## 9. Advanced Features

### 9.1 SFTP File Browser
- Connects via `SftpClient` from dartssh2
- Directory navigation with breadcrumb path in AppBar
- File operations: view (text), rename, delete, create folder
- File type icons based on extension
- Human-readable file sizes

### 9.2 SSH Tunneling
- **Local forward:** binds local `ServerSocket`, relays to remote via `forwardLocal`
- **Remote forward:** uses `forwardRemote` to accept remote connections, relays to local
- Live tunnel list with start/stop controls
- Segmented button to switch between local/remote mode

### 9.3 Snippet Manager
- CRUD for saved command snippets (name, command, description)
- Persisted to secure storage as JSON
- Accessible from home screen and terminal screen
- Terminal integration: tap snippet → sends command + newline to active session

### 9.4 Connection Groups & Tags
- `group` field for broad categorization (e.g. "Production", "Staging")
- `tags` list for fine-grained labeling (e.g. "web", "db", "us-east")
- Group filter chips on home screen
- Tags searchable and displayed on connection tiles

### 9.5 Export/Import
- Export: serializes all connections to JSON, copies to clipboard
- Import: paste JSON dialog, imports non-duplicate connections
- Available in Settings screen
