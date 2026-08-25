import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DefaultApi
void main() {
  final instance = Openapi().getDefaultApi();

  group(DefaultApi, () {
    // Get latest content manifest
    //
    // Returns the active release manifest including checksums for offline sync.
    //
    //Future<Manifest> getManifest() async
    test('test getManifest', () async {
      // TODO
    });

    // Get current user profile
    //
    //Future<UserProfile> getMe() async
    test('test getMe', () async {
      // TODO
    });

    // List ecosystems
    //
    // Get all ecosystems available for learning.
    //
    //Future<BuiltList<Ecosystem>> listEcosystems() async
    test('test listEcosystems', () async {
      // TODO
    });

    // List levels
    //
    // Get levels and user progress.
    //
    //Future<BuiltList<Level>> listLevels() async
    test('test listLevels', () async {
      // TODO
    });

  });
}
