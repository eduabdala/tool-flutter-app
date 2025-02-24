import 'package:flutter/material.dart';
import 'package:perto_tools/common/home/models/tab_manager.dart';
import 'package:perto_tools/common/home/views/tab_screen.dart';
import 'package:perto_tools/core/themes/theme_provider.dart';
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

    // Verifica se o botão de adicionar aba está presente
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Adiciona uma nova aba
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verifica se a nova aba foi adicionada
    expect(find.text('Tab 2'), findsOneWidget);

    // Seleciona a aba adicionada
    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();

    // Verifica se a aba foi selecionada
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

    // Verifica se o ícone do tema está presente antes de interagir com ele
// Verifica se o ícone do tema está presente antes de interagir com ele
    expect(find.byIcon(Icons.nightlight_round), findsOneWidget);

// Verifica o estado inicial do tema
    final initialThemeNotifier = Provider.of<ThemeNotifier>(
        tester.element(find.byType(TabScreen)),
        listen: false);
    expect(initialThemeNotifier.isDarkMode, isTrue); // Inicialmente escuro

// Troca o tema
    await tester.tap(find.byIcon(Icons.nightlight_round));
    await tester.pumpAndSettle(); // Espera a UI ser completamente atualizada

// Verifica se o tema foi trocado
    final themeNotifier = Provider.of<ThemeNotifier>(
        tester.element(find.byType(TabScreen)),
        listen: false);
    expect(themeNotifier.isDarkMode, isFalse); // Agora claro

// Verifica o ícone do tema após a troca
    await tester
        .pumpAndSettle(); // Certifica que todos os widgets foram atualizados
    expect(find.byIcon(Icons.wb_sunny),
        findsOneWidget); // Verifica se o ícone correto é mostrado
  });
}
