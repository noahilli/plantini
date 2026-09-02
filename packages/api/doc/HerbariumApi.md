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
[**getObservation**](HerbariumApi.md#getobservation) | **GET** /observations/{observationId} | Read one caller-owned observation
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
