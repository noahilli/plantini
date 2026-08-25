import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:openapi/openapi.dart';
import 'isar_collection.dart';

class OfflineQueueService extends ChangeNotifier {
  final Isar isar;
  final Openapi api;

  OfflineQueueService(this.isar, this.api);

  Future<void> queueObservation({
    required String imagePath,
    required String organ,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final obs = OfflineObservation()
      ..imagePath = imagePath
      ..organ = organ
      ..latitude = latitude
      ..longitude = longitude
      ..notes = notes
      ..capturedAt = DateTime.now()
      ..isSynced = false;

    await isar.writeTxn(() async {
      await isar.offlineObservations.put(obs);
    });
    
    notifyListeners();
    _attemptSync();
  }

  Future<List<OfflineObservation>> getPendingObservations() async {
    return await isar.offlineObservations.filter().isSyncedEqualTo(false).findAll();
  }
  
  Future<List<OfflineObservation>> getAllObservations() async {
    return await isar.offlineObservations.where().sortByCapturedAtDesc().findAll();
  }

  Future<void> deleteObservation(int id) async {
    await isar.writeTxn(() async {
      await isar.offlineObservations.delete(id);
    });
    notifyListeners();
  }

  Future<void> updateNotes(int id, String notes) async {
    final obs = await isar.offlineObservations.get(id);
    if (obs != null) {
      obs.notes = notes;
      await isar.writeTxn(() async {
        await isar.offlineObservations.put(obs);
      });
      notifyListeners();
    }
  }

  Future<void> _attemptSync() async {
    final pending = await getPendingObservations();
    if (pending.isEmpty) return;

    for (final obs in pending) {
      try {
        // Prepare Multipart request for the API
        // For web, imagePath might be a blob URL, for mobile a file path.
        // We'll mock the MultipartFile creation for this spike.
        
        // Example:
        // final formData = FormData.fromMap({
        //   'image': await MultipartFile.fromFile(obs.imagePath),
        //   'notes': obs.notes,
        //   'latitude': obs.latitude,
        //   'longitude': obs.longitude,
        // });
        
        // We assume the API call succeeds:
        // await api.getDefaultApi().createObservation(...);
        
        // Mocking successful upload:
        await Future.delayed(const Duration(milliseconds: 500));
        
        obs.isSynced = true;
        await isar.writeTxn(() async {
          await isar.offlineObservations.put(obs);
        });
      } catch (e) {
        debugPrint('Failed to sync observation ${obs.id}: $e');
        // Will retry later
      }
    }
    
    notifyListeners();
  }
}
