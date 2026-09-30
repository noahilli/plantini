# openapi.model.Observation

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  |
**clientObservationId** | **String** |  |
**observedAt** | [**DateTime**](DateTime.md) |  |
**note** | **String** |  | [optional]
**confirmedPlantId** | **String** |  | [optional]
**speciesKey** | **String** | Set when the confirmed species is not in the catalogue; see /species/{speciesKey}. | [optional]
**speciesName** | **String** |  | [optional]
**mediaId** | **String** |  | [optional]
**mediaUrl** | **String** | Path of the photo, see /media/{mediaId}/content. | [optional]
**location** | [**ObservationLocation**](ObservationLocation.md) |  | [optional]
**identification** | [**IdentificationJob**](IdentificationJob.md) |  | [optional]
**version** | **String** |  |
**syncStatus** | **String** |  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
