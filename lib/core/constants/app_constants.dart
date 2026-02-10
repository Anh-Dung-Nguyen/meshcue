class AppConstants {
  static const double defaultLatitude = 16.0544;
  static const double defaultLongitude = 108.2022;
  static const double defaultZoom = 13.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;

  static const String openStreetMapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String mapStoreName = 'vietnamMaps';

  static const double defaultWarningRadius = 5.0;

  static const String databaseName = 'meshcue_connect.db';
  static const int databaseVersion = 1;

  static const String warningChannelId = 'meshcue_warnings';
  static const String warningChannelName = 'Meshcue Warnings';

  static const String warningCheckTask = 'checkMeshcueWarnings';
  static const Duration backgroundCheckInterval = Duration(minutes: 15);
}