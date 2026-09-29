# openapi.model.CompletionRule

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**minimumScore** | **num** |  |
**requiredQuizIds** | **BuiltList&lt;String&gt;** |  | [optional]
**requiredLevelIds** | **BuiltList&lt;String&gt;** |  | [optional]
**requiredPlantIds** | **BuiltSet&lt;String&gt;** | Explicit collection targets. Ecosystem-scoped ordinary levels return []; only the final level lists the three public UUIDs. Clients must not infer targets from plantIds. | [optional]
**collectionScope** | **String** | Legacy rules default to level and retain their per-level collection gate. Ecosystem rules never block quiz completion; GET ecosystem progress evaluates the final collection gate. | [optional] [default to 'level']

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
