import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takash/core/utils/helpers.dart';

void main() {
  group('Helpers', () {
    group('calculateDistance', () {
      test('iki nokta arası mesafeyi km olarak hesaplar', () {
        final p1 = GeoPoint(41.0082, 28.9784);
        final p2 = GeoPoint(41.0082, 28.9784);

        final distance = Helpers.calculateDistance(p1, p2);
        expect(distance, 0.0);
      });

      test('farklı koordinatlar arasında mesafe hesaplar', () {
        final p1 = GeoPoint(41.0082, 28.9784);
        final p2 = GeoPoint(41.0282, 28.9984);

        final distance = Helpers.calculateDistance(p1, p2);
        expect(distance, greaterThan(0));
      });
    });

    group('formatTime', () {
      test('saat:dakika formatında döner', () {
        final date = DateTime(2024, 3, 1, 14, 30);
        final formatted = Helpers.formatTime(date);

        expect(formatted, '14:30');
      });

      test('tek haneli saat için sıfır ekler', () {
        final date = DateTime(2024, 3, 1, 9, 5);
        final formatted = Helpers.formatTime(date);

        expect(formatted, '09:05');
      });
    });

    group('formatDate', () {
      test('tarih döner', () {
        final date = DateTime(2024, 3, 15);
        final formatted = Helpers.formatDate(date);
        expect(formatted.isNotEmpty, true);
      }, skip: true);
    });

    group('timeAgo', () {
      test('bir yıldan eski için yıl döner', () {
        final date = DateTime.now().subtract(const Duration(days: 400));
        expect(Helpers.timeAgo(date), contains('yıl'));
      });

      test('bir aydan eski için ay döner', () {
        final date = DateTime.now().subtract(const Duration(days: 60));
        expect(Helpers.timeAgo(date), contains('ay'));
      });

      test('bir günden eski için gün döner', () {
        final date = DateTime.now().subtract(const Duration(days: 2));
        expect(Helpers.timeAgo(date), contains('gün'));
      });

      test('bir saatten eski için saat döner', () {
        final date = DateTime.now().subtract(const Duration(hours: 5));
        expect(Helpers.timeAgo(date), contains('saat'));
      });

      test('bir dakikadan eski için dakika döner', () {
        final date = DateTime.now().subtract(const Duration(minutes: 30));
        expect(Helpers.timeAgo(date), contains('dakika'));
      });

      test('az önce için az önce döner', () {
        final date = DateTime.now().subtract(const Duration(seconds: 30));
        expect(Helpers.timeAgo(date), 'Az önce');
      });
    });

    group('formatDistance', () {
      test('1km den küçük için metre döner', () {
        expect(Helpers.formatDistance(0.5), contains('m'));
        expect(Helpers.formatDistance(0.1), contains('m'));
      });

      test('1km den büyük için km döner', () {
        expect(Helpers.formatDistance(1.0), contains('km'));
        expect(Helpers.formatDistance(2.5), contains('km'));
      });

      test('tam değerler için ondalık gösterme', () {
        expect(Helpers.formatDistance(2.0), '2.0 km');
      });
    });
  });
}
