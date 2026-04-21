import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_client/main.dart';

void main() {
  testWidgets('App renders with bottom navigation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SSHClientApp()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('Snippets'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
