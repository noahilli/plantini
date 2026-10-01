import '../../catalog/presentation/widgets/world_module.dart';

enum ExplorerGroup {
  female('Frauen'),
  male('Männer'),
  diverse('Divers');

  const ExplorerGroup(this.label);
  final String label;
}

/// One of the nine fixed explorer characters (modelled in Blender, see
/// `tools/blender/create_explorer_characters.py`). The player picks one; the
/// choice is just its [id].
final class Explorer {
  const Explorer({
    required this.id,
    required this.name,
    required this.group,
    required this.blurb,
    required this.meshes,
  });

  final String id;
  final String name;
  final ExplorerGroup group;

  /// One line about the character ("Vogelkundlerin mit Fernglas").
  final String blurb;

  /// Meshes with motion `ranger`, so every 3D view places them where the
  /// default ranger stands.
  final List<WorldMesh> meshes;
}
