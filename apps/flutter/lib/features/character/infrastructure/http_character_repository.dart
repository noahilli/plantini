import '../../../adapters/http/platform_api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/character_repository.dart';

/// Reads and writes the chosen explorer as part of the profile (`/me`).
final class HttpCharacterRepository implements CharacterRepository {
  const HttpCharacterRepository(this._client);

  final PlatformApiClient _client;

  static const version = 2;

  static String? _idOf(Object? character) =>
      character is Map && character['v'] == version && character['id'] is String
      ? character['id'] as String
      : null;

  @override
  Future<Result<String?>> load() async {
    final response = await _client.getJson('me', requiresAuthentication: true);
    return response.when(
      // A record from the old character designer (v1) counts as "none": the
      // player picks one of the new explorers.
      success: (value) => Result.success(_idOf(value.body['character'])),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<String>> save(String explorerId) async {
    final response = await _client.patchJson(
      'me',
      body: {
        'character': {'v': version, 'id': explorerId},
      },
    );
    return response.when(
      success: (value) {
        final id = _idOf(value.body['character']);
        if (id == null) {
          return Result.failure(
            const ContractFailure(
              message: 'Der Server hat den Charakter nicht bestätigt.',
              missingFields: ['character'],
            ),
          );
        }
        return Result.success(id);
      },
      failure: Result.failure,
    );
  }
}
