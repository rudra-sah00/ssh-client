import 'package:flutter/material.dart';

class TerminalControlBar extends StatefulWidget {
  final void Function(String) onKeyTap;
  const TerminalControlBar({super.key, required this.onKeyTap});

  @override
  State<TerminalControlBar> createState() => _TerminalControlBarState();
}

class _TerminalControlBarState extends State<TerminalControlBar> {
  bool _ctrlActive = false;
  bool _altActive = false;

  void _sendKey(String key) {
    String out = key;
    if (_ctrlActive) {
      // Ctrl+key: send ASCII control char (A=1, B=2, ..., Z=26)
      if (key.length == 1 && RegExp(r'[a-zA-Z]').hasMatch(key)) {
        out = String.fromCharCode(key.toUpperCase().codeUnitAt(0) - 64);
      }
      setState(() => _ctrlActive = false);
    }
    if (_altActive) {
      out = '\x1b$out';
      setState(() => _altActive = false);
    }
    widget.onKeyTap(out);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _toggle('Ctrl', _ctrlActive, () => setState(() => _ctrlActive = !_ctrlActive)),
            _toggle('Alt', _altActive, () => setState(() => _altActive = !_altActive)),
            _key('Esc', '\x1b'),
            _key('Tab', '\t'),
            _key('↑', '\x1b[A'),
            _key('↓', '\x1b[B'),
            _key('→', '\x1b[C'),
            _key('←', '\x1b[D'),
            _key('Home', '\x1b[H'),
            _key('End', '\x1b[F'),
            _key('PgUp', '\x1b[5~'),
            _key('PgDn', '\x1b[6~'),
            _key('Del', '\x1b[3~'),
            _key('Ins', '\x1b[2~'),
            _key('F1', '\x1bOP'),
            _key('F2', '\x1bOQ'),
            _key('F3', '\x1bOR'),
            _key('F4', '\x1bOS'),
            _key('F5', '\x1b[15~'),
            _key('|', '|'),
            _key('/', '/'),
            _key('-', '-'),
            _key('~', '~'),
            // Dismiss keyboard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Icon(Icons.keyboard_hide_rounded, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _key(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _sendKey(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _toggle(String label, bool active, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: active ? cs.primary : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? cs.onPrimary : cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
