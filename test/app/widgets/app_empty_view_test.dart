import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/app/localization/app_localizations.dart';
import 'package:master_service/app/localization/tk_flutter_localizations.dart';
import 'package:master_service/app/widgets/app_empty_view.dart';

void main() {
  testWidgets('AppEmptyView shows title, message and action button', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tk'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          TkMaterialLocalizationsDelegate(),
          TkCupertinoLocalizationsDelegate(),
          TkWidgetsLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppEmptyView(
            title: 'Empty title',
            message: 'Empty message',
            onAction: () => tapped = true,
            actionLabel: 'Add item',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Empty title'), findsOneWidget);
    expect(find.text('Empty message'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    await tester.tap(find.text('Add item'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
