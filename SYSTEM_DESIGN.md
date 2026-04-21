# SSH Client — System Design

## 1. Overview

A production-ready Flutter SSH client with interactive terminal, SFTP browser, SSH tunneling, multi-session management, and secure credential storage. Pure client-side — no auth, no backend required. Targets iOS and Android.

## 2. Architecture

**Pattern:** Clean Architecture + Riverpod for state management.

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  Screens → Widgets → Riverpod UI   │
├─────────────────────────────────────┤
│          Provider Layer             │
│  Riverpod Providers (state logic)   │
├─────────────────────────────────────┤
│            Data Layer               │
│  Services → Models → Storage        │
├─────────────────────────────────────┤
│          External Packages          │
│  dartssh2 · xterm · secure_storage  │
└─────────────────────────────────────┘
```

## 3. Navigation

Three-tab bottom navigation (instant switch, no animation):

| Tab | Screen | Description |
|---|---|---|
| Servers | `HomeScreen` | Saved connections list, add/edit/delete |
| Sessions | `SessionsScreen` | Active SSH sessions, resume/disconnect |
| Settings | `SettingsScreen` | Theme, terminal, connection, snippets, data |

Additional push routes: Terminal, Add/Edit Server (slide right-to-left), SFTP Browser, Tunnels, Snippets.

## 4. Core Modules

### 4.1 SSH Module (`dartssh2`)
- Connect/disconnect lifecycle
- Password & private key authentication
- Interactive shell sessions (PTY, xterm-256color)
- Terminal resize support

### 4.2 Terminal Module (`xterm`)
- Full terminal emulation widget
- Bidirectional data binding: SSH stdout → terminal display, terminal input → SSH stdin
- JetBrains Mono font, configurable font size
- Mobile control bar: Ctrl, Alt, Esc, Tab, arrows, F-keys, common chars, keyboard dismiss

### 4.3 Multi-Session Manager (`ChangeNotifier`)
- `SessionManager` holds all active `SshSession` instances globally
- Sessions survive navigation — press back from terminal, session stays alive
- Resume existing session when tapping same connection (no duplicate connections)
- Each session owns: `SshServiceImpl` + `Terminal` + keep-alive timer
- UI rebuilds automatically via `ChangeNotifierProvider`

### 4.4 Auto-Reconnect
- `WidgetsBindingObserver` detects `AppLifecycleState.resumed`
- If SSH socket is dead, reconnects using same `Terminal` instance (preserves scrollback)
- Shows `[Connection lost]` / `[Reconnected]` messages in terminal
- Auto-runs `tmux attach` if tmux session exists on server

### 4.5 Connection Management
- CRUD operations for saved connections
- Credentials encrypted via `flutter_secure_storage` (Keychain/Keystore)
- Connection model fields: `id`, `name`, `host`, `port`, `username`, `password`, `privateKeyPath`, `passphrase`, `useKeyAuth`, `lastConnected`, `group`, `tags`
- Freezed immutability + JSON serialization
- Long-press for edit/delete actions
- Search by name and host

### 4.6 State Management (`riverpod`)
- `connectionListProvider` — saved connections (StateNotifier + secure storage)
- `sessionManagerProvider` — active SSH sessions (ChangeNotifierProvider)
- `settingsProvider` — app preferences (StateNotifier + secure storage)
- `snippetListProvider` — saved command snippets (StateNotifier + secure storage)

### 4.7 Theming
- Dark/light mode toggle (Switch in Settings)
- Default: system theme on first launch, then user's choice persisted
- `flex_color_scheme` for consistent Material 3 theming
- Grey accent palette (`#8E8E93`)
- Dark: pure black `#000000`, cards `#0F0F0F` (theme) / `#1C1C1E` (settings)
- Light: iOS grey `#F2F2F7`, white cards

### 4.8 Typography
- **Titles & Headings** — Space Grotesk
- **Body Text** — Inter
- **Terminal** — JetBrains Mono

### 4.9 Background Keep-Alive
- Per-session periodic timer prevents idle disconnect
- Configurable interval (default 30s) and max session duration (0 = forever)
- Connection timeout setting (default 30s)
- Toggle on/off in Settings
- Timer auto-cancels on session close

## 5. Data Flow

```
User taps server in Servers tab
  → Check SessionManager for existing session
  → If exists: resume with existing Terminal instance
  → If not: SessionManager.createSession()
    → dartssh2 opens SSH connection + PTY shell
    → Bind: SSH stdout → Terminal.write()
    → Bind: Terminal.onOutput → SSH stdin
    → Bind: Terminal.onResize → SSH resize
  → Push TerminalScreen with session
  → User presses back → session stays alive in SessionManager
  → Sessions tab shows active session

App goes to background → iOS suspends socket
  → User returns → WidgetsBindingObserver detects resume
  → Socket dead? → reconnectSession() with same Terminal
  → tmux available? → auto-attach
```

## 6. Security

| Concern | Solution |
|---|---|
| Credential storage | `flutter_secure_storage` (Keychain/Keystore) |
| Private keys | Stored encrypted, never in plaintext |
| Transport | SSH protocol (encrypted by default) |
| No backend | Pure client-side, no data leaves device |

## 7. Folder Structure

```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── errors/          # Custom exceptions (sealed class)
│   ├── router/          # Named routes + slide transitions
│   └── theme/           # FlexColorScheme dark/light config
├── data/
│   ├── models/
│   │   ├── connection/  # ConnectionModel (freezed)
│   │   ├── settings/    # SettingsModel (freezed)
│   │   └── snippet/     # SnippetModel (freezed)
│   ├── providers/       # All Riverpod providers
│   └── services/
│       ├── sftp/        # SftpService
│       ├── ssh/         # SshServiceImpl, SessionManager
│       ├── storage/     # SecureStorageServiceImpl
│       └── tunnel/      # TunnelService
└── presentation/
    ├── screens/
    │   ├── connection/  # Add/Edit Server (full page, slide transition)
    │   ├── home/        # Servers list
    │   ├── sessions/    # Active sessions
    │   ├── settings/    # App settings
    │   ├── sftp/        # SFTP file browser
    │   ├── shell/       # Bottom nav shell (IndexedStack)
    │   ├── snippet/     # Snippet manager
    │   ├── terminal/    # Terminal with xterm + auto-reconnect
    │   └── tunnel/      # SSH tunnel manager
    └── widgets/
        └── terminal/    # Mobile control bar
```

## 8. Key Dependencies

| Package | Purpose |
|---|---|
| `dartssh2` | SSH2 protocol client |
| `xterm` | Terminal emulator widget |
| `flutter_riverpod` | State management |
| `flex_color_scheme` | Theming (dark/light) |
| `google_fonts` | Typography (Space Grotesk, Inter, JetBrains Mono) |
| `flutter_animate` | UI animations |
| `flutter_secure_storage` | Encrypted credential storage |
| `freezed_annotation` | Immutable data models |
| `json_annotation` | JSON serialization |

## 9. Advanced Features

### 9.1 SFTP File Browser
- Directory navigation with breadcrumb path
- File operations: view (text), rename, delete, create folder
- File type icons based on extension
- Human-readable file sizes

### 9.2 SSH Tunneling
- Local forward: binds local ServerSocket, relays to remote
- Remote forward: accepts remote connections, relays to local
- Live tunnel list with start/stop controls

### 9.3 Snippet Manager
- CRUD for saved command snippets (name, command, description)
- Persisted to secure storage
- Accessible from Settings > Manage Snippets

### 9.4 Export/Import
- Export: serializes all connections to JSON, copies to clipboard
- Import: paste JSON, imports non-duplicate connections
- Available in Settings > Data section
