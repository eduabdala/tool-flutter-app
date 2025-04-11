import 'package:flutter/material.dart';
import 'package:flutter_tools/common/home/models/tab_manager.dart';
import 'package:flutter_tools/common/home/views/tab_screen.dart';
import 'package:flutter_tools/core/themes/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Verifica a navegação entre abas', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TabManager()),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ],
        child: MaterialApp(
          home: TabScreen(),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Tab 2'), findsOneWidget);

    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();

    expect(find.text('Tab 2'), findsOneWidget);
  });

  testWidgets('Verifica a troca de tema', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TabManager()),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ],
        child: MaterialApp(
          home: TabScreen(),
        ),
      ),
    );
    expect(find.byIcon(Icons.nightlight_round), findsOneWidget);

    final initialThemeNotifier = Provider.of<ThemeNotifier>(
        tester.element(find.byType(TabScreen)),
        listen: false);
    expect(initialThemeNotifier.isDarkMode, isTrue);

    await tester.tap(find.byIcon(Icons.nightlight_round));
    await tester.pumpAndSettle();

    final themeNotifier = Provider.of<ThemeNotifier>(
        tester.element(find.byType(TabScreen)),
        listen: false);
    expect(themeNotifier.isDarkMode, isFalse);

    await tester
        .pumpAndSettle();
    expect(find.byIcon(Icons.wb_sunny),
        findsOneWidget);
  });
}
