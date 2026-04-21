import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_client/main.dart';

void main() {
  testWidgets('App renders home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SSHClientApp()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('SSH Client'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
