import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:takash/features/profile/presentation/settings_screen.dart';
import 'package:takash/core/providers.dart';
import 'package:takash/features/auth/data/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsScreen section başlıklarını göstermeli', (tester) async {
    final mockAuth = MockFirebaseAuth();
    final mockFirestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          firestoreProvider.overrideWithValue(mockFirestore),
          authRepositoryProvider.overrideWithValue(
            AuthRepository(auth: mockAuth, firestore: mockFirestore),
          ),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Görünüm'), findsOneWidget);
    expect(find.text('Bildirimler'), findsOneWidget);
    expect(find.text('Gizlilik'), findsOneWidget);
  });

  testWidgets('Tema seçenekleri görünmeli', (tester) async {
    final mockAuth = MockFirebaseAuth();
    final mockFirestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseAuthProvider.overrideWithValue(mockAuth),
          firestoreProvider.overrideWithValue(mockFirestore),
          authRepositoryProvider.overrideWithValue(
            AuthRepository(auth: mockAuth, firestore: mockFirestore),
          ),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Açık Tema'), findsOneWidget);
    expect(find.text('Koyu Tema'), findsOneWidget);
    expect(find.text('Sistem Varsayılanı'), findsOneWidget);
  });
}
