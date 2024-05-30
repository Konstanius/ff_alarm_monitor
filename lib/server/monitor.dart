class Monitor {
  static final Map<String, Monitor> preparedMonitors = {};

  int id;
  String name;
  int stationId;
  List<int> units;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime expiresAt;
  
  Monitor({
    required this.id,
    required this.name,
    required this.stationId,
    required this.units,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "stationId": stationId,
      "units": units,
      "createdAt": createdAt.millisecondsSinceEpoch,
      "updatedAt": updatedAt.millisecondsSinceEpoch,
      "expiresAt": expiresAt.millisecondsSinceEpoch,
    };
  }

  factory Monitor.fromJson(Map<String, dynamic> json) {
    return Monitor(
      id: json['id'],
      name: json['name'],
      stationId: json['stationId'],
      units: List<int>.from(json['units']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt']),
    );
  }
}
