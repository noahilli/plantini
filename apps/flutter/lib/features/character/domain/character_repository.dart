import '../../../core/result.dart';
import 'character_spec.dart';

abstract interface class CharacterRepository {
  /// The saved character, or success(null) if the player has none yet.
  Future<Result<CharacterSpec?>> load();

  Future<Result<CharacterSpec>> save(CharacterSpec spec);
}
