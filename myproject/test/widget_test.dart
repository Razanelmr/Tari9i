import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myproject/main.dart';
import 'package:myproject/Phone_Page/Phone_Screen.dart';

void main() {
  testWidgets('HomePage affiche le bouton Suivant et navigue vers PhoneNumberPage',
      (WidgetTester tester) async {
    // Créer l'application avec isLoggedIn = false
    await tester.pumpWidget(
      const MaterialApp(
        home: MyApp(isLoggedIn: false, userId: null),
      ),
    );

    // Vérifie que le texte "Vroom" est présent
    expect(find.text('Vroom'), findsOneWidget);

    // Vérifie que le bouton "Suivant" est présent
    expect(find.text('Suivant'), findsOneWidget);

    // Clique sur le bouton
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle(); // attendre que la navigation se fasse

    // Vérifie qu'on est bien sur PhoneNumberPage
    expect(find.byType(PhoneNumberPage), findsOneWidget);
  });
}
