import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/app/localization/app_localizations.dart';
import 'package:master_service/app/localization/tk_flutter_localizations.dart';
import 'package:master_service/app/widgets/app_error_view.dart';

void main() {
  testWidgets('AppErrorView shows message and retry button', (tester) async {
    var retried = false;

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
          body: AppErrorView(
            message: 'Test error',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test error'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();

    expect(retried, isTrue);
  });
}
