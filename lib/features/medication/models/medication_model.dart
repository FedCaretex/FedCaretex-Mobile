class MedicationSchedule {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final bool isTaken;

  MedicationSchedule({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isTaken = false,
  });

  MedicationSchedule copyWith({
    String? id,
    String? name,
    String? dosage,
    String? time,
    bool? isTaken,
  }) {
    return MedicationSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
