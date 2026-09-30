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

    // Share of accounts that collected each plant or species
    //
    // Aggregated over all accounts. Below a minimum number of accounts no shares are published (`available` is false). Shares are shown in per cent, or in per mille below one per cent.
    //
    //Future<CollectionStats> getCollectionStats() async
    test('test getCollectionStats', () async {
      // TODO
    });

    // Read one caller-owned observation
    //
    //Future<Observation> getObservation(String observationId) async
    test('test getObservation', () async {
      // TODO
    });

    // Read one of the caller's own uploaded photos
    //
    // Owner-scoped; another account's media id is indistinguishable from a missing one. The bytes behind an id never change, so the response is immutable and clients cache it for good. `width` returns a resized JPEG (longest side) for thumbnails.
    //
    //Future<Uint8List> getPrivateMediaContent(String mediaId, { int width }) async
    test('test getPrivateMediaContent', () async {
      // TODO
    });

    // Info card of a species found by users that is not part of any ecosystem
    //
    // Built once from public sources and cached for all users. Never listed in ecosystems or levels.
    //
    //Future<SpeciesCard> getSpeciesCard(String speciesKey) async
    test('test getSpeciesCard', () async {
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
