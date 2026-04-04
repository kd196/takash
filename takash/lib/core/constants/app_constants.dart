/// Uygulama genelinde kullanılan sabitler
class AppConstants {
  // Geofencing yarıçapları (km)
  static const double defaultRadiusKm = 10.0;
  static const double minRadiusKm = 1.0;
  static const double maxRadiusKm = 50.0;

  // İlan limitleri
  static const int maxListingImages = 5;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int listingsPerPage = 20;

  // Profil fotoğrafı boyutu (bytes)
  static const int maxProfilePhotoSize = 5 * 1024 * 1024; // 5MB
}
