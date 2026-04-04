import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Yardımcı fonksiyonlar
class Helpers {
  // ... (mevcut metodlar)
  
  // İki koordinat arası mesafeyi hesapla (km)
  static double calculateDistance(GeoPoint p1, GeoPoint p2) {
    return Geolocator.distanceBetween(
      p1.latitude, p1.longitude,
      p2.latitude, p2.longitude,
    ) / 1000; // Metreden KM'ye çevir
  }
  // Zaman formatlama (Sadece saat:dakika)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Tarih formatlama
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'tr_TR').format(date);
  }

  // Zaman farkı (örn: "2 saat önce")
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  // Mesafe formatlama
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }
}
