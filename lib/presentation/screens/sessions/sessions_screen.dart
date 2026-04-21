import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssh_client/data/providers/providers.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mgr = ref.watch(sessionManagerProvider);
    final sessions = mgr.activeSessions;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: const Text('Sessions'),
          ),
          if (sessions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No active sessions', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: 17)),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < sessions.length; i++) ...[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          title: Text(
                            sessions[i].connection.name,
                            style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${sessions[i].connection.username}@${sessions[i].connection.host}:${sessions[i].connection.port}',
                            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.38), fontSize: 13),
                          ),
                          leading: Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: sessions[i].isConnected ? const Color(0xFF8E8E93) : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () => mgr.closeSession(sessions[i].id),
                            child: Text('Disconnect', style: TextStyle(color: Colors.red.shade400, fontSize: 14)),
                          ),
                          onTap: () => Navigator.pushNamed(context, '/terminal', arguments: sessions[i].connection),
                        ),
                        if (i < sessions.length - 1)
                          Divider(height: 1, indent: 16, endIndent: 16, color: cs.onSurface.withValues(alpha: 0.08)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
