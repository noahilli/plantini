# openapi.api.HerbariumApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://127.0.0.1:1338/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createObservation**](HerbariumApi.md#createobservation) | **POST** /observations | Create an idempotent private observation
[**deleteObservation**](HerbariumApi.md#deleteobservation) | **DELETE** /observations/{observationId} | Create an observation tombstone
[**getCollectionStats**](HerbariumApi.md#getcollectionstats) | **GET** /stats/collection | Share of accounts that collected each plant or species
[**getMapTile**](HerbariumApi.md#getmaptile) | **GET** /tiles/{z}/{x}/{y} | Map tile for the herbarium map
[**getObservation**](HerbariumApi.md#getobservation) | **GET** /observations/{observationId} | Read one caller-owned observation
[**getPrivateMediaContent**](HerbariumApi.md#getprivatemediacontent) | **GET** /media/{mediaId}/content | Read one of the caller&#39;s own uploaded photos
[**getSpeciesCard**](HerbariumApi.md#getspeciescard) | **GET** /species/{speciesKey} | Info card of a species found by users that is not part of any ecosystem
[**getSpeciesPhoto**](HerbariumApi.md#getspeciesphoto) | **GET** /species/{speciesKey}/photo | Photo of a species card (server-side cached copy)
[**listObservations**](HerbariumApi.md#listobservations) | **GET** /observations | List caller-owned herbarium observations
[**updateObservation**](HerbariumApi.md#updateobservation) | **PATCH** /observations/{observationId} | Update an observation with optimistic concurrency


# **createObservation**
> Observation createObservation(idempotencyKey, createObservationRequest)

Create an idempotent private observation

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final String idempotencyKey = idempotencyKey_example; // String |
final CreateObservationRequest createObservationRequest = ; // CreateObservationRequest |

try {
    final response = api.createObservation(idempotencyKey, createObservationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->createObservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |
 **createObservationRequest** | [**CreateObservationRequest**](CreateObservationRequest.md)|  |

### Return type

[**Observation**](Observation.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteObservation**
> deleteObservation(observationId, ifMatch)

Create an observation tombstone

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final String observationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String ifMatch = ifMatch_example; // String |

try {
    api.deleteObservation(observationId, ifMatch);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->deleteObservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **observationId** | **String**|  |
 **ifMatch** | **String**|  |

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCollectionStats**
> CollectionStats getCollectionStats()

Share of accounts that collected each plant or species

Aggregated over all accounts. Below a minimum number of accounts no shares are published (`available` is false). Shares are shown in per cent, or in per mille below one per cent.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();

try {
    final response = api.getCollectionStats();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->getCollectionStats: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CollectionStats**](CollectionStats.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMapTile**
> Uint8List getMapTile(z, x, y)

Map tile for the herbarium map

OpenStreetMap tile, fetched and cached by the server so the app never contacts the tile provider. Requires a signed-in user (the endpoint is not an open proxy). Zoom 0-18.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final int z = 56; // int |
final int x = 56; // int |
final int y = 56; // int |

try {
    final response = api.getMapTile(z, x, y);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->getMapTile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **z** | **int**|  |
 **x** | **int**|  |
 **y** | **int**|  |

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/png, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getObservation**
> Observation getObservation(observationId)

Read one caller-owned observation

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final String observationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getObservation(observationId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->getObservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **observationId** | **String**|  |

### Return type

[**Observation**](Observation.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPrivateMediaContent**
> Uint8List getPrivateMediaContent(mediaId, width)

Read one of the caller's own uploaded photos

Owner-scoped; another account's media id is indistinguishable from a missing one. The bytes behind an id never change, so the response is immutable and clients cache it for good. `width` returns a resized JPEG (longest side) for thumbnails.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final int width = 56; // int |

try {
    final response = api.getPrivateMediaContent(mediaId, width);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->getPrivateMediaContent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mediaId** | **String**|  |
 **width** | **int**|  | [optional]

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/jpeg, image/png, image/webp, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSpeciesCard**
> SpeciesCard getSpeciesCard(speciesKey)

Info card of a species found by users that is not part of any ecosystem

Built once from public sources and cached for all users. Never listed in ecosystems or levels.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final String speciesKey = speciesKey_example; // String |

try {
    final response = api.getSpeciesCard(speciesKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->getSpeciesCard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **speciesKey** | **String**|  |

### Return type

[**SpeciesCard**](SpeciesCard.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSpeciesPhoto**
> Uint8List getSpeciesPhoto(speciesKey, photoId)

Photo of a species card (server-side cached copy)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final String speciesKey = speciesKey_example; // String |
final String photoId = photoId_example; // String | Identifier from the card; makes the response immutable.

try {
    final response = api.getSpeciesPhoto(speciesKey, photoId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->getSpeciesPhoto: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **speciesKey** | **String**|  |
 **photoId** | **String**| Identifier from the card; makes the response immutable. | [optional]

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/jpeg, image/png, image/webp, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listObservations**
> ObservationPage listObservations(page, pageSize)

List caller-owned herbarium observations

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final int page = 56; // int |
final int pageSize = 56; // int |

try {
    final response = api.listObservations(page, pageSize);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->listObservations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] [default to 1]
 **pageSize** | **int**|  | [optional] [default to 50]

### Return type

[**ObservationPage**](ObservationPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateObservation**
> Observation updateObservation(observationId, ifMatch, updateObservationRequest)

Update an observation with optimistic concurrency

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getHerbariumApi();
final String observationId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String ifMatch = ifMatch_example; // String |
final UpdateObservationRequest updateObservationRequest = ; // UpdateObservationRequest |

try {
    final response = api.updateObservation(observationId, ifMatch, updateObservationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HerbariumApi->updateObservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **observationId** | **String**|  |
 **ifMatch** | **String**|  |
 **updateObservationRequest** | [**UpdateObservationRequest**](UpdateObservationRequest.md)|  |

### Return type

[**Observation**](Observation.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
