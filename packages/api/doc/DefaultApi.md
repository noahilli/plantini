# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.plantini.local/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createObservation**](DefaultApi.md#createobservation) | **POST** /observations | Create a new observation and trigger PlantNet identification
[**getManifest**](DefaultApi.md#getmanifest) | **GET** /manifest | Get latest content manifest
[**getMe**](DefaultApi.md#getme) | **GET** /me | Get current user profile
[**getPlant**](DefaultApi.md#getplant) | **GET** /plants/{id} | Get a specific plant
[**listEcosystems**](DefaultApi.md#listecosystems) | **GET** /ecosystem | List ecosystems
[**listLevels**](DefaultApi.md#listlevels) | **GET** /level | List levels
[**listMedia**](DefaultApi.md#listmedia) | **GET** /media | List media
[**listObservations**](DefaultApi.md#listobservations) | **GET** /observations | List user observations (Herbarium)
[**listPlants**](DefaultApi.md#listplants) | **GET** /plants | List plants
[**listQuizzes**](DefaultApi.md#listquizzes) | **GET** /quizzes | List quizzes


# **createObservation**
> Observation createObservation(image, notes, latitude, longitude)

Create a new observation and trigger PlantNet identification

PlantNet-Adapter-Flow: 1. Client uploads an image with optional metadata. 2. Backend creates a pending observation record. 3. Backend async worker sends the image to the PlantNet-Mock API. 4. Mock API returns a probabilistic taxon match and score. 5. Backend compares the result with expected species or saves it to the Herbarium. 6. Client can poll or wait for the updated observation status. 

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final MultipartFile image = BINARY_DATA_HERE; // MultipartFile | 
final String notes = notes_example; // String | 
final num latitude = 8.14; // num | 
final num longitude = 8.14; // num | 

try {
    final response = api.createObservation(image, notes, latitude, longitude);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->createObservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **image** | **MultipartFile**|  | [optional] 
 **notes** | **String**|  | [optional] 
 **latitude** | **num**|  | [optional] 
 **longitude** | **num**|  | [optional] 

### Return type

[**Observation**](Observation.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getManifest**
> Manifest getManifest()

Get latest content manifest

Returns the active release manifest including checksums for offline sync.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.getManifest();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getManifest: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Manifest**](Manifest.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMe**
> UserProfile getMe()

Get current user profile

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.getMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserProfile**](UserProfile.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlant**
> Plant getPlant(id)

Get a specific plant

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String id = id_example; // String | 

try {
    final response = api.getPlant(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->getPlant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Plant**](Plant.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEcosystems**
> BuiltList<Ecosystem> listEcosystems()

List ecosystems

Get all ecosystems available for learning.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.listEcosystems();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listEcosystems: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Ecosystem&gt;**](Ecosystem.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLevels**
> BuiltList<Level> listLevels()

List levels

Get levels and user progress.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.listLevels();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listLevels: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Level&gt;**](Level.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMedia**
> BuiltList<Media> listMedia()

List media

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.listMedia();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listMedia: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Media&gt;**](Media.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listObservations**
> BuiltList<Observation> listObservations()

List user observations (Herbarium)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.listObservations();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listObservations: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Observation&gt;**](Observation.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlants**
> BuiltList<Plant> listPlants()

List plants

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.listPlants();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listPlants: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Plant&gt;**](Plant.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listQuizzes**
> BuiltList<Quiz> listQuizzes()

List quizzes

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.listQuizzes();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->listQuizzes: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Quiz&gt;**](Quiz.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

