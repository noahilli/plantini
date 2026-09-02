import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for ProfileApi
void main() {
  final instance = Openapi().getProfileApi();

  group(ProfileApi, () {
    // Request caller account deletion
    //
    //Future<AdministrativeJob> createPrivacyDeletion(String idempotencyKey) async
    test('test createPrivacyDeletion', () async {
      // TODO
    });

    // Request a caller's machine-readable data export
    //
    //Future<AdministrativeJob> createPrivacyExport(String idempotencyKey) async
    test('test createPrivacyExport', () async {
      // TODO
    });

    // Read the authenticated profile
    //
    //Future<UserProfile> getMe() async
    test('test getMe', () async {
      // TODO
    });

    // Search authorized user administration records
    //
    //Future<AdminUserPage> listAdminUsers({ int page, int pageSize }) async
    test('test listAdminUsers', () async {
      // TODO
    });

    // Suspend a user and revoke active sessions
    //
    //Future<AdministrativeJob> suspendUser(String userId, String idempotencyKey) async
    test('test suspendUser', () async {
      // TODO
    });

    // Update permitted profile preferences
    //
    //Future<UserProfile> updateMe(UpdateProfileRequest updateProfileRequest) async
    test('test updateMe', () async {
      // TODO
    });
  });
}
