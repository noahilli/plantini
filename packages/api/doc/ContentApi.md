# openapi.api.ContentApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://127.0.0.1:1338/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createContentRelease**](ContentApi.md#createcontentrelease) | **POST** /admin/content-releases | Validate and publish a content release
[**createImport**](ContentApi.md#createimport) | **POST** /admin/imports | Validate or import versioned editorial data
[**getAdminDashboard**](ContentApi.md#getadmindashboard) | **GET** /admin/dashboard | Read privacy-preserving aggregated editorial metrics
[**getContentChanges**](ContentApi.md#getcontentchanges) | **GET** /content/changes | Read released content changes and deletion tombstones
[**getContentManifest**](ContentApi.md#getcontentmanifest) | **GET** /content/manifest | Read the active immutable content manifest
[**getEcosystem**](ContentApi.md#getecosystem) | **GET** /ecosystems/{ecosystemId} | Read one published ecosystem
[**getLevel**](ContentApi.md#getlevel) | **GET** /levels/{levelId} | Read an accessible level and its user state
[**getPlant**](ContentApi.md#getplant) | **GET** /plants/{plantId} | Read one published plant profile
[**listEcosystems**](ContentApi.md#listecosystems) | **GET** /ecosystems | List published ecosystems


# **createContentRelease**
> AdministrativeJob createContentRelease(idempotencyKey, createContentReleaseRequest)

Validate and publish a content release

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();
final String idempotencyKey = idempotencyKey_example; // String |
final CreateContentReleaseRequest createContentReleaseRequest = ; // CreateContentReleaseRequest |

try {
    final response = api.createContentRelease(idempotencyKey, createContentReleaseRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->createContentRelease: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |
 **createContentReleaseRequest** | [**CreateContentReleaseRequest**](CreateContentReleaseRequest.md)|  |

### Return type

[**AdministrativeJob**](AdministrativeJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createImport**
> AdministrativeJob createImport(idempotencyKey, createImportRequest)

Validate or import versioned editorial data

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();
final String idempotencyKey = idempotencyKey_example; // String |
final CreateImportRequest createImportRequest = ; // CreateImportRequest |

try {
    final response = api.createImport(idempotencyKey, createImportRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->createImport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |
 **createImportRequest** | [**CreateImportRequest**](CreateImportRequest.md)|  |

### Return type

[**AdministrativeJob**](AdministrativeJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminDashboard**
> AdminDashboard getAdminDashboard()

Read privacy-preserving aggregated editorial metrics

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();

try {
    final response = api.getAdminDashboard();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->getAdminDashboard: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminDashboard**](AdminDashboard.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getContentChanges**
> ContentChangePage getContentChanges(since)

Read released content changes and deletion tombstones

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();
final String since = since_example; // String |

try {
    final response = api.getContentChanges(since);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->getContentChanges: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **since** | **String**|  | [optional]

### Return type

[**ContentChangePage**](ContentChangePage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getContentManifest**
> ContentManifest getContentManifest(ifNoneMatch)

Read the active immutable content manifest

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();
final String ifNoneMatch = ifNoneMatch_example; // String |

try {
    final response = api.getContentManifest(ifNoneMatch);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->getContentManifest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ifNoneMatch** | **String**|  | [optional]

### Return type

[**ContentManifest**](ContentManifest.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEcosystem**
> Ecosystem getEcosystem(ecosystemId)

Read one published ecosystem

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();
final String ecosystemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getEcosystem(ecosystemId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->getEcosystem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ecosystemId** | **String**|  |

### Return type

[**Ecosystem**](Ecosystem.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLevel**
> Level getLevel(levelId)

Read an accessible level and its user state

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();
final String levelId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getLevel(levelId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->getLevel: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **levelId** | **String**|  |

### Return type

[**Level**](Level.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlant**
> Plant getPlant(plantId)

Read one published plant profile

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();
final String plantId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getPlant(plantId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->getPlant: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **plantId** | **String**|  |

### Return type

[**Plant**](Plant.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEcosystems**
> EcosystemPage listEcosystems(page, pageSize)

List published ecosystems

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getContentApi();
final int page = 56; // int |
final int pageSize = 56; // int |

try {
    final response = api.listEcosystems(page, pageSize);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ContentApi->listEcosystems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] [default to 1]
 **pageSize** | **int**|  | [optional] [default to 50]

### Return type

[**EcosystemPage**](EcosystemPage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
