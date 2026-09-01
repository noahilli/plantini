import 'local_database.dart';

Future<LocalDatabase?> createLocalDatabase() async {
  final result = await LocalDatabase.open();
  return result.valueOrNull;
}
