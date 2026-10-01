import '../../../core/result.dart';

abstract interface class CharacterRepository {
  /// The id of the saved explorer, or success(null) if none was chosen yet
  /// (or the saved record is from an older app version).
  Future<Result<String?>> load();

  Future<Result<String>> save(String explorerId);
}
