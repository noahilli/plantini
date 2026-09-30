import '../../../adapters/http/platform_api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/character_repository.dart';
import '../domain/character_spec.dart';

/// Reads and writes the character as part of the profile (`/me`).
final class HttpCharacterRepository implements CharacterRepository {
  const HttpCharacterRepository(this._client);

  final PlatformApiClient _client;

  @override
  Future<Result<CharacterSpec?>> load() async {
    final response = await _client.getJson('me', requiresAuthentication: true);
    return response.when(
      success: (value) {
        final raw = value.body['character'];
        if (raw == null) return Result.success(null);
        // A character this app version cannot read is treated as missing, so
        // the player is asked to make a new one instead of seeing nothing.
        return Result.success(CharacterSpec.fromJson(raw));
      },
      failure: Result.failure,
    );
  }

  @override
  Future<Result<CharacterSpec>> save(CharacterSpec spec) async {
    final response = await _client.patchJson(
      'me',
      body: {'character': spec.toJson()},
    );
    return response.when(
      success: (value) {
        final saved = CharacterSpec.fromJson(value.body['character']);
        if (saved == null) {
          return Result.failure(
            const ContractFailure(
              message: 'Der Server hat den Charakter nicht bestätigt.',
              missingFields: ['character'],
            ),
          );
        }
        return Result.success(saved);
      },
      failure: Result.failure,
    );
  }
}
