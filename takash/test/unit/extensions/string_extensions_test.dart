import 'package:flutter_test/flutter_test.dart';
import 'package:takash/core/extensions/string_extensions.dart';

void main() {
  group('StringExtensions', () {
    group('capitalize', () {
      test('boş string için boş döner', () {
        expect(''.capitalize, '');
      });

      test('tek karakteri büyük yapar', () {
        expect('a'.capitalize, 'A');
      });

      test('ilk harfi büyük yapar', () {
        expect('merhaba'.capitalize, 'Merhaba');
        expect('HELLO'.capitalize, 'HELLO');
      });

      test('zaten büyük harfle başlayanı değiştirmez', () {
        expect('Merhaba'.capitalize, 'Merhaba');
      });
    });

    group('isValidEmail', () {
      test('geçersiz formatlar için false döner', () {
        expect('test'.isValidEmail, false);
        expect('test@'.isValidEmail, false);
        expect('@example.com'.isValidEmail, false);
        expect('test@example'.isValidEmail, false);
        expect(''.isValidEmail, false);
      });

      test('geçerli e-postalar için true döner', () {
        expect('test@example.com'.isValidEmail, true);
        expect('user.name@domain.org'.isValidEmail, true);
        expect('user+tag@example.co.uk'.isValidEmail, true);
      });
    });

    group('trimmed', () {
      test('boşlukları temizler', () {
        expect('  merhaba  '.trimmed, 'merhaba');
        expect('\ttest\t'.trimmed, 'test');
        expect('\n multiline \n'.trimmed, 'multiline');
      });

      test('ortadaki boşlukları korur', () {
        expect('merhaba dunya'.trimmed, 'merhaba dunya');
      });
    });
  });
}
