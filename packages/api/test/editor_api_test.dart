import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for EditorApi
void main() {
  final instance = Openapi().getEditorApi();

  group(EditorApi, () {
    // Approve a pending change editorially; release remains separate (reviewer role)
    //
    //Future<EditorChange> approveEditorChange(String changeId, { EditorReviewRequest editorReviewRequest }) async
    test('test approveEditorChange', () async {
      // TODO
    });

    // Create a role-scoped editorial draft; does not publish
    //
    //Future<EditorChange> createEditorChange(EditorSaveRequest editorSaveRequest) async
    test('test createEditorChange', () async {
      // TODO
    });

    // Invite an editor, reviewer or teacher
    //
    // Only systemadministration may invite botanisches_review or lehrende; this restriction is checked by the server. Invitations for lehrende use the configured teacher portal origin and OIDC client for the target redirect.
    //
    //Future<EditorInvitation> createEditorInvitation(EditorInvitationRequest editorInvitationRequest) async
    test('test createEditorInvitation', () async {
      // TODO
    });

    // Read the editorial relationship tree (currently at most 1000 records per kind)
    //
    //Future<EditorCatalog> getEditorCatalog() async
    test('test getEditorCatalog', () async {
      // TODO
    });

    // Read an editorial change visible to the caller
    //
    //Future<EditorChange> getEditorChange(String changeId) async
    test('test getEditorChange', () async {
      // TODO
    });

    // Read role-scoped editorial counters
    //
    //Future<EditorDashboard> getEditorDashboard() async
    test('test getEditorDashboard', () async {
      // TODO
    });

    // Read a published or draft CMS item as an editable payload
    //
    //Future<EditorItem> getEditorItem(String type, String itemId) async
    test('test getEditorItem', () async {
      // TODO
    });

    // List own drafts and reviews, or all changes for reviewers
    //
    //Future<BuiltList<EditorChange>> listEditorChanges() async
    test('test listEditorChanges', () async {
      // TODO
    });

    // Reject a pending change with a reason (reviewer role)
    //
    //Future<EditorChange> rejectEditorChange(String changeId, EditorReviewRequest editorReviewRequest) async
    test('test rejectEditorChange', () async {
      // TODO
    });

    // Submit own draft for botanical review
    //
    //Future<EditorChange> submitEditorChange(String changeId) async
    test('test submitEditorChange', () async {
      // TODO
    });

    // Update own draft or rejected change; does not publish
    //
    //Future<EditorChange> updateEditorChange(String changeId, EditorSaveRequest editorSaveRequest) async
    test('test updateEditorChange', () async {
      // TODO
    });
  });
}
