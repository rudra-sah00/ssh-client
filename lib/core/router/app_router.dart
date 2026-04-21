import 'package:flutter/material.dart';
import 'package:ssh_client/data/models/connection/connection_model.dart';
import 'package:ssh_client/presentation/screens/connection/add_edit_connection_screen.dart';
import 'package:ssh_client/presentation/screens/settings/settings_screen.dart';
import 'package:ssh_client/presentation/screens/sftp/sftp_browser_screen.dart';
import 'package:ssh_client/presentation/screens/shell/app_shell.dart';
import 'package:ssh_client/presentation/screens/snippet/snippet_screen.dart';
import 'package:ssh_client/presentation/screens/terminal/terminal_screen.dart';
import 'package:ssh_client/presentation/screens/tunnel/tunnel_screen.dart';

abstract class AppRouter {
  static const String home = '/';
  static const String terminal = '/terminal';
  static const String addConnection = '/add-connection';
  static const String settings = '/settings';
  static const String sftp = '/sftp';
  static const String tunnel = '/tunnel';
  static const String snippets = '/snippets';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const AppShell());
      case terminal:
        final conn = s.arguments! as ConnectionModel;
        return MaterialPageRoute(builder: (_) => TerminalScreen(connection: conn));
      case addConnection:
        final conn = s.arguments as ConnectionModel?;
        return MaterialPageRoute(builder: (_) => AddEditConnectionScreen(existing: conn));
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case sftp:
        final conn = s.arguments! as ConnectionModel;
        return MaterialPageRoute(builder: (_) => SftpBrowserScreen(connection: conn));
      case tunnel:
        final conn = s.arguments! as ConnectionModel;
        return MaterialPageRoute(builder: (_) => TunnelScreen(connection: conn));
      case snippets:
        final onSend = s.arguments as void Function(String)?;
        return MaterialPageRoute(builder: (_) => SnippetScreen(onSend: onSend));
      default:
        return MaterialPageRoute(builder: (_) => const AppShell());
    }
  }
}
