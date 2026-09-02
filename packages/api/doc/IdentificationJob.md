# openapi.model.IdentificationJob

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**status** | **String** |  |
**createdAt** | [**DateTime**](DateTime.md) |  |
**attempts** | **int** |  |
**retryAfter** | [**DateTime**](DateTime.md) |  | [optional]
**candidates** | [**BuiltList&lt;IdentificationCandidate&gt;**](IdentificationCandidate.md) |  | [optional]
**providerMetadata** | [**IdentificationProviderMetadata**](IdentificationProviderMetadata.md) |  | [optional]
**expectedPlantId** | **String** |  | [optional]
**expectedMatch** | **String** |  | [optional]
**expectedCandidateId** | **String** |  | [optional]
**failureCode** | **String** |  | [optional]
**deadLetteredAt** | [**DateTime**](DateTime.md) |  | [optional]
**confirmedPlantId** | **String** |  | [optional]
**confirmedCandidateId** | **String** |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
