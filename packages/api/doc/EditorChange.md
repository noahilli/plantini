# openapi.model.EditorChange

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**type** | **String** |  |
**targetId** | **String** |  |
**data** | [**JsonObject**](.md) |  |
**status** | **String** |  |
**author** | **String** |  |
**reviewer** | **String** |  | [optional]
**note** | **String** |  | [optional]
**updatedAt** | [**DateTime**](DateTime.md) |  |
**reviewedAt** | [**DateTime**](DateTime.md) |  | [optional]
**appliedAt** | [**DateTime**](DateTime.md) |  | [optional]
**reviewEvents** | [**BuiltList&lt;JsonObject&gt;**](JsonObject.md) |  |
**payloadHash** | **String** |  | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
