class WaterModel {
  final int id;
  final int amountMl;
  final DateTime time;

  const WaterModel({
    required this.id,
    required this.amountMl,
    required this.time,
  });

  factory WaterModel.fromJson(Map<String, dynamic> json) {
    return WaterModel(
      id:       (json['water_id'] as num).toInt(),
      amountMl: (json['amount_ml'] as num).toInt(),
      time:     DateTime.parse(json['time'] as String),
    );
  }
}