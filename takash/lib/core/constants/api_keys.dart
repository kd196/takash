import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API anahtarlarını .env dosyasından okur
class ApiKeys {
  static String get mapboxToken {
    return dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  }

  static String get streamApiKey {
    return dotenv.env['STREAM_API_KEY'] ?? '';
  }
}
