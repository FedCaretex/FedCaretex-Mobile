import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_model.dart';

class MedicationNotifier extends Notifier<List<MedicationSchedule>> {
  @override
  List<MedicationSchedule> build() {
    return [
      MedicationSchedule(id: '1', name: 'Metformin', dosage: '500mg (After Meal)', time: '08:00 AM', isTaken: true),
      MedicationSchedule(id: '2', name: 'Aspirin', dosage: '100mg', time: '01:00 PM', isTaken: false),
      MedicationSchedule(id: '3', name: 'Simvastatin', dosage: '20mg', time: '08:00 PM', isTaken: false),
    ];
  }

  void toggleTakenStatus(String id) {
    state = [
      for (final med in state)
        if (med.id == id) med.copyWith(isTaken: !med.isTaken) else med,
    ];
  }
}

final medicationListProvider = NotifierProvider<MedicationNotifier, List<MedicationSchedule>>(() {
  return MedicationNotifier();
});
