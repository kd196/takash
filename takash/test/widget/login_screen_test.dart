import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:takash/features/auth/presentation/login_screen.dart';
import 'package:takash/features/auth/presentation/auth_controller.dart';
import 'package:takash/core/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen', () {
    testWidgets('giriş formunu gösterir', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Takaş'), findsOneWidget);
      expect(find.text('E-posta'), findsOneWidget);
      expect(find.text('Şifre'), findsOneWidget);
      expect(find.text('Giriş Yap'), findsOneWidget);
    });

    testWidgets('Google ile giriş butonunu gösterir', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Google ile Devam Et'), findsOneWidget);
    });

    testWidgets('kayıt ol linkini gösterir', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Hesabın yok mu?'), findsOneWidget);
      expect(find.text('Kayıt Ol'), findsOneWidget);
    });

    testWidgets('şifremi unuttum butonunu gösterir', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pump();

      expect(find.text('Şifremi Unuttum'), findsOneWidget);
    });
  });
}
