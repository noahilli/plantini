# openapi.model.EcosystemProgress

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**ecosystemId** | **String** |  |
**status** | **String** |  |
**completed** | **bool** | True only when every published level has a server-passed attempt and every target species is collected. |
**totalLevels** | **int** |  |
**completedLevelCount** | **int** |  |
**completedLevelIds** | **BuiltSet&lt;String&gt;** | Passed level IDs in sequence order. |
**requiredPlantIds** | **BuiltSet&lt;String&gt;** |  |
**collectedPlantIds** | **BuiltSet&lt;String&gt;** | Distinct collected required species only. |
**missingPlantIds** | **BuiltSet&lt;String&gt;** |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
