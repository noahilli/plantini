import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for HerbariumApi
void main() {
  final instance = Openapi().getHerbariumApi();

  group(HerbariumApi, () {
    // Create an idempotent private observation
    //
    //Future<Observation> createObservation(String idempotencyKey, CreateObservationRequest createObservationRequest) async
    test('test createObservation', () async {
      // TODO
    });

    // Create an observation tombstone
    //
    //Future deleteObservation(String observationId, String ifMatch) async
    test('test deleteObservation', () async {
      // TODO
    });

    // Read one caller-owned observation
    //
    //Future<Observation> getObservation(String observationId) async
    test('test getObservation', () async {
      // TODO
    });

    // List caller-owned herbarium observations
    //
    //Future<ObservationPage> listObservations({ int page, int pageSize }) async
    test('test listObservations', () async {
      // TODO
    });

    // Update an observation with optimistic concurrency
    //
    //Future<Observation> updateObservation(String observationId, String ifMatch, UpdateObservationRequest updateObservationRequest) async
    test('test updateObservation', () async {
      // TODO
    });
  });
}
