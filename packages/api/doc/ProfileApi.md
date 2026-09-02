# openapi.api.ProfileApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://127.0.0.1:1338/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createPrivacyDeletion**](ProfileApi.md#createprivacydeletion) | **POST** /privacy/deletions | Request caller account deletion
[**createPrivacyExport**](ProfileApi.md#createprivacyexport) | **POST** /privacy/exports | Request a caller&#39;s machine-readable data export
[**getMe**](ProfileApi.md#getme) | **GET** /me | Read the authenticated profile
[**listAdminUsers**](ProfileApi.md#listadminusers) | **GET** /admin/users | Search authorized user administration records
[**suspendUser**](ProfileApi.md#suspenduser) | **POST** /admin/users/{userId}/suspend | Suspend a user and revoke active sessions
[**updateMe**](ProfileApi.md#updateme) | **PATCH** /me | Update permitted profile preferences


# **createPrivacyDeletion**
> AdministrativeJob createPrivacyDeletion(idempotencyKey)

Request caller account deletion

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getProfileApi();
final String idempotencyKey = idempotencyKey_example; // String |

try {
    final response = api.createPrivacyDeletion(idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->createPrivacyDeletion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |

### Return type

[**AdministrativeJob**](AdministrativeJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPrivacyExport**
> AdministrativeJob createPrivacyExport(idempotencyKey)

Request a caller's machine-readable data export

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getProfileApi();
final String idempotencyKey = idempotencyKey_example; // String |

try {
    final response = api.createPrivacyExport(idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->createPrivacyExport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |

### Return type

[**AdministrativeJob**](AdministrativeJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMe**
> UserProfile getMe()

Read the authenticated profile

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getProfileApi();

try {
    final response = api.getMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->getMe: $e\n');
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
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAdminUsers**
> AdminUserPage listAdminUsers(page, pageSize)

Search authorized user administration records

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getProfileApi();
final int page = 56; // int |
final int pageSize = 56; // int |

try {
    final response = api.listAdminUsers(page, pageSize);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->listAdminUsers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] [default to 1]
 **pageSize** | **int**|  | [optional] [default to 50]

### Return type

[**AdminUserPage**](AdminUserPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **suspendUser**
> AdministrativeJob suspendUser(userId, idempotencyKey)

Suspend a user and revoke active sessions

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getProfileApi();
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String idempotencyKey = idempotencyKey_example; // String |

try {
    final response = api.suspendUser(userId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->suspendUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  |
 **idempotencyKey** | **String**|  |

### Return type

[**AdministrativeJob**](AdministrativeJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateMe**
> UserProfile updateMe(updateProfileRequest)

Update permitted profile preferences

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getProfileApi();
final UpdateProfileRequest updateProfileRequest = ; // UpdateProfileRequest |

try {
    final response = api.updateMe(updateProfileRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->updateMe: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateProfileRequest** | [**UpdateProfileRequest**](UpdateProfileRequest.md)|  |

### Return type

[**UserProfile**](UserProfile.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
