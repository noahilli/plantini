import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for TeachingApi
void main() {
  final instance = Openapi().getTeachingApi();

  group(TeachingApi, () {
    // Create an owned class
    //
    //Future<TeachingClass> createTeachingClass(TeachingCreateClassRequest teachingCreateClassRequest) async
    test('test createTeachingClass', () async {
      // TODO
    });

    // Create a managed learner in an owned class
    //
    //Future<TeachingCreateStudentResponse> createTeachingStudent(String classId, TeachingCreateStudentRequest teachingCreateStudentRequest) async
    test('test createTeachingStudent', () async {
      // TODO
    });

    // Read an owned class and student progress
    //
    //Future<TeachingClassDetail> getTeachingClass(String classId) async
    test('test getTeachingClass', () async {
      // TODO
    });

    // Read progress across owned classes
    //
    //Future<TeachingDashboard> getTeachingDashboard() async
    test('test getTeachingDashboard', () async {
      // TODO
    });

    // Read the authenticated teaching session
    //
    //Future<TeachingSession> getTeachingSession() async
    test('test getTeachingSession', () async {
      // TODO
    });

    // List owned classes
    //
    //Future<TeachingClassList> listTeachingClasses() async
    test('test listTeachingClasses', () async {
      // TODO
    });

    // Reset a managed learner password
    //
    // No request body is needed. An empty JSON object is accepted for compatibility; any fields or non-object bodies are rejected with 400.
    //
    //Future<TeachingResetPasswordResponse> resetTeachingStudentPassword(String studentId) async
    test('test resetTeachingStudentPassword', () async {
      // TODO
    });

    // Enable or disable an owned managed learner
    //
    //Future<TeachingUpdateStudentResponse> updateTeachingStudent(String studentId, TeachingUpdateStudentRequest teachingUpdateStudentRequest) async
    test('test updateTeachingStudent', () async {
      // TODO
    });
  });
}
