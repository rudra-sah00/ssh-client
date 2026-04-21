import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_client/main.dart';

void main() {
  testWidgets('App renders home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SSHClientApp()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Servers'), findsAtLeast(1));
    expect(find.text('Add Server'), findsOneWidget);
  });
}
