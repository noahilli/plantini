import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

/// tests for FieldApi
void main() {
  final instance = Openapi().getFieldApi();

  group(FieldApi, () {
    // Confirm one candidate before it can enter the private herbarium
    //
    //Future<IdentificationJob> confirmIdentification(String jobId, ConfirmIdentificationRequest confirmIdentificationRequest) async
    test('test confirmIdentification', () async {
      // TODO
    });

    // Create an asynchronous identification job
    //
    //Future<IdentificationJob> createIdentification(String idempotencyKey, CreateIdentificationRequest createIdentificationRequest) async
    test('test createIdentification', () async {
      // TODO
    });

    // Reserve a private media upload
    //
    //Future<MediaUpload> createMediaUpload(String idempotencyKey, CreateUploadRequest createUploadRequest) async
    test('test createMediaUpload', () async {
      // TODO
    });

    // Read a caller-owned identification job
    //
    //Future<IdentificationJob> getIdentification(String jobId) async
    test('test getIdentification', () async {
      // TODO
    });

    // Schedule a controlled identification retry
    //
    //Future<IdentificationJob> retryIdentification(String jobId, String idempotencyKey) async
    test('test retryIdentification', () async {
      // TODO
    });

    // Upload bytes to a caller-owned short-lived media reservation
    //
    //Future<MediaUpload> uploadPrivateMediaContent(String mediaId, MultipartFile image) async
    test('test uploadPrivateMediaContent', () async {
      // TODO
    });
  });
}
