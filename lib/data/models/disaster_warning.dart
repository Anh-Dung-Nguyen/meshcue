import 'package:equatable/equatable.dart';

enum WarningType {
  flood,
  storm,
  typhoon,
  landslide,
  heavyRain,
  flashFlood,
  other
}

enum Severity {
  low,
  medium,
  high,
  critical
}

class DisasterWarning {
  final String id;
  final WarningType type;
  final Severity severity;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final DateTime timestamp;
  final DateTime? expiresAt;
  final double radiusKm;
  final String? reportedBy;
  final String? source;
  final int upvotes;
  final bool isVerfied;

  const DisasterWarning ({
    required this.id,
    required this.type,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    required this.timestamp,
    this.expiresAt,
    this.radiusKm = 5.0,
    this.reportedBy,
    this.source = 'community',
    this.upvotes = 0,
    this.isVerfied = false,
  });

  @override
  List<Object?> get props => [
    id, type, severity, latitude, longitude, timestamp, radiusKm
  ];

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'latitude': latitude,
      'longitude': longitude,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'radiusKm': radiusKm,
      'reportedBy': reportedBy,
      'source': source,
      'upvotes': upvotes,
      'isVerified': isVerfied ? 1 : 0,
    };
  }

  factory DisasterWarning.fromJSON(Map<String, dynamic> json) {
    return DisasterWarning(
      id: json['id'] as String, 
      type: WarningType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WarningType.other,
      ),
      severity: Severity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => Severity.low,
      ),
      latitude: (json['latitude'] as num).toDouble(), 
      longitude: (json['longitude'] as num).toDouble(), 
      title: json['title'] as String, 
      description: json['description'] as String, 
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiresAt: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'] as String)
        : null,
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 5.0,
      reportedBy: json['reportedBy'] as String?,
      source: json['source'] as String? ?? 'community',
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      isVerfied: (json['isVerified'] as num?) == 1,
    );
  }

  DisasterWarning copyWith ({
    String? id,
    WarningType? type,
    Severity? severity,
    double? latitude,
    double? longitude,
    String? title,
    String? description,
    DateTime? timestamp,
    DateTime? expiresAt,
    double? radiusKm,
    String? reportedBy,
    String? source,
    int? upvotes,
    bool? isVerfied,
  }) {
    return DisasterWarning(
      id: id ?? this.id, 
      type: type ?? this.type, 
      severity: severity ?? this.severity, 
      latitude: latitude ?? this.latitude, 
      longitude: longitude ?? this.longitude, 
      title: title ?? this.title, 
      description: description ?? this.description, 
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      radiusKm: radiusKm ?? this.radiusKm,
      reportedBy: reportedBy ?? this.reportedBy,
      source: source ?? this.source,
      upvotes: upvotes ?? this.upvotes,
      isVerfied: isVerfied ?? this.isVerfied,
    );
  }

  bool get isActive {
    if (expiresAt == null) {
      return true;
    }

    return DateTime.now().isBefore(expiresAt!);
  }

  int get ageInHours {
    return DateTime.now().difference(timestamp).inHours;
  }
}