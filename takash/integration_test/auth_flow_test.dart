import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:takash/main.dart' as app;
import 'package:takash/core/providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow Integration Tests', () {
    testWidgets('login screen renders correctly', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: app.TakashApp()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Takaş'), findsOneWidget);
      expect(find.text('Giriş Yap'), findsOneWidget);
    });

    testWidgets('login form validation works', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: app.TakashApp()),
        ),
      );

      await tester.pumpAndSettle();

      final loginButton = find.text('Giriş Yap');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Geçerli bir e-posta girin'), findsOneWidget);
    });

    testWidgets('google login button is visible', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: app.TakashApp()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Google ile Devam Et'), findsOneWidget);
    });

    testWidgets('password reset dialog opens', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: app.TakashApp()),
        ),
      );

      await tester.pumpAndSettle();

      final forgotPasswordButton = find.text('Şifremi Unuttum');
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      expect(find.text('Şifremi Sıfırla'), findsOneWidget);
    });
  });
}
