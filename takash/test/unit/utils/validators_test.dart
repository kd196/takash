import 'package:flutter_test/flutter_test.dart';
import 'package:takash/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('null değer için hata döner', () {
        expect(Validators.email(null), 'E-posta adresi gerekli');
      });

      test('boş değer için hata döner', () {
        expect(Validators.email(''), 'E-posta adresi gerekli');
      });

      test('geçersiz format için hata döner', () {
        expect(Validators.email('test'), 'Geçerli bir e-posta adresi girin');
        expect(Validators.email('test@'), 'Geçerli bir e-posta adresi girin');
        expect(Validators.email('@example.com'),
            'Geçerli bir e-posta adresi girin');
      });

      test('geçerli e-posta için null döner', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.org'), isNull);
        expect(Validators.email('user+tag@example.co.uk'), isNull);
      });
    });

    group('password', () {
      test('null değer için hata döner', () {
        expect(Validators.password(null), 'Şifre gerekli');
      });

      test('boş değer için hata döner', () {
        expect(Validators.password(''), 'Şifre gerekli');
      });

      test('6 karakterden az için hata döner', () {
        expect(Validators.password('12345'), 'Şifre en az 6 karakter olmalı');
        expect(Validators.password(''), 'Şifre gerekli');
      });

      test('geçerli şifre için null döner', () {
        expect(Validators.password('123456'), isNull);
        expect(Validators.password('password'), isNull);
        expect(Validators.password('12345678'), isNull);
      });
    });

    group('displayName', () {
      test('null değer için hata döner', () {
        expect(Validators.displayName(null), 'İsim gerekli');
      });

      test('boş değer için hata döner', () {
        expect(Validators.displayName(''), 'İsim gerekli');
      });

      test('2 karakterden az için hata döner', () {
        expect(Validators.displayName('A'), 'İsim en az 2 karakter olmalı');
      });

      test('geçerli isim için null döner', () {
        expect(Validators.displayName('Ahmet'), isNull);
        expect(Validators.displayName('Mehmet'), isNull);
        expect(Validators.displayName('AB'), isNull);
      });
    });

    group('listingTitle', () {
      test('null değer için hata döner', () {
        expect(Validators.listingTitle(null), 'Başlık gerekli');
      });

      test('boş değer için hata döner', () {
        expect(Validators.listingTitle(''), 'Başlık gerekli');
      });

      test('3 karakterden az için hata döner', () {
        expect(Validators.listingTitle('AB'), 'Başlık en az 3 karakter olmalı');
      });

      test('100 karakterden fazla için hata döner', () {
        final longTitle = 'A' * 101;
        expect(Validators.listingTitle(longTitle),
            'Başlık en fazla 100 karakter olabilir');
      });

      test('geçerli başlık için null döner', () {
        expect(Validators.listingTitle('iPhone 13'), isNull);
        expect(Validators.listingTitle('ABC'), isNull);
      });
    });

    group('listingDescription', () {
      test('null değer için hata döner', () {
        expect(Validators.listingDescription(null), 'Açıklama gerekli');
      });

      test('boş değer için hata döner', () {
        expect(Validators.listingDescription(''), 'Açıklama gerekli');
      });

      test('10 karakterden az için hata döner', () {
        expect(Validators.listingDescription('Kısa'),
            'Açıklama en az 10 karakter olmalı');
      });

      test('geçerli açıklama için null döner', () {
        expect(
            Validators.listingDescription('Bu uzun bir açıklamadır'), isNull);
      });
    });
  });
}
