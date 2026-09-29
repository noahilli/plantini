import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for ContentApi
void main() {
  final instance = Openapi().getContentApi();

  group(ContentApi, () {
    // Validate and publish a content release
    //
    //Future<AdministrativeJob> createContentRelease(String idempotencyKey, CreateContentReleaseRequest createContentReleaseRequest) async
    test('test createContentRelease', () async {
      // TODO
    });

    // Validate or import versioned editorial data
    //
    //Future<AdministrativeJob> createImport(String idempotencyKey, CreateImportRequest createImportRequest) async
    test('test createImport', () async {
      // TODO
    });

    // Read privacy-preserving aggregated editorial metrics
    //
    //Future<AdminDashboard> getAdminDashboard() async
    test('test getAdminDashboard', () async {
      // TODO
    });

    // Read released content changes and deletion tombstones
    //
    //Future<ContentChangePage> getContentChanges({ String since }) async
    test('test getContentChanges', () async {
      // TODO
    });

    // Read the active immutable content manifest
    //
    //Future<ContentManifest> getContentManifest({ String ifNoneMatch }) async
    test('test getContentManifest', () async {
      // TODO
    });

    // Read one published ecosystem
    //
    //Future<Ecosystem> getEcosystem(String ecosystemId) async
    test('test getEcosystem', () async {
      // TODO
    });

    // Read an accessible level and its user state
    //
    //Future<Level> getLevel(String levelId) async
    test('test getLevel', () async {
      // TODO
    });

    // Read one published plant profile
    //
    //Future<Plant> getPlant(String plantId) async
    test('test getPlant', () async {
      // TODO
    });

    // Read an attributed supplemental photo for a published plant
    //
    // Without photoId the primary supplemental photo is returned. The plant profile lists up to ten photos (authored first) whose URLs carry the photoId of each supplemental photo.
    //
    //Future<Uint8List> getPlantPhoto(String plantId, { String photoId }) async
    test('test getPlantPhoto', () async {
      // TODO
    });

    // List published ecosystems
    //
    //Future<EcosystemPage> listEcosystems({ int page, int pageSize }) async
    test('test listEcosystems', () async {
      // TODO
    });
  });
}
