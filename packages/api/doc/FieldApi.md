# openapi.api.FieldApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://127.0.0.1:1338/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**confirmIdentification**](FieldApi.md#confirmidentification) | **POST** /identifications/{jobId}/confirm | Confirm one candidate before it can enter the private herbarium
[**createIdentification**](FieldApi.md#createidentification) | **POST** /identifications | Create an asynchronous identification job
[**createMediaUpload**](FieldApi.md#createmediaupload) | **POST** /media/uploads | Reserve a private media upload
[**getIdentification**](FieldApi.md#getidentification) | **GET** /identifications/{jobId} | Read a caller-owned identification job
[**retryIdentification**](FieldApi.md#retryidentification) | **POST** /identifications/{jobId}/retry | Schedule a controlled identification retry
[**uploadPrivateMediaContent**](FieldApi.md#uploadprivatemediacontent) | **POST** /media/uploads/{mediaId}/content | Upload bytes to a caller-owned short-lived media reservation


# **confirmIdentification**
> IdentificationJob confirmIdentification(jobId, confirmIdentificationRequest)

Confirm one candidate before it can enter the private herbarium

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFieldApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final ConfirmIdentificationRequest confirmIdentificationRequest = ; // ConfirmIdentificationRequest |

try {
    final response = api.confirmIdentification(jobId, confirmIdentificationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FieldApi->confirmIdentification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |
 **confirmIdentificationRequest** | [**ConfirmIdentificationRequest**](ConfirmIdentificationRequest.md)|  |

### Return type

[**IdentificationJob**](IdentificationJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createIdentification**
> IdentificationJob createIdentification(idempotencyKey, createIdentificationRequest)

Create an asynchronous identification job

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFieldApi();
final String idempotencyKey = idempotencyKey_example; // String |
final CreateIdentificationRequest createIdentificationRequest = ; // CreateIdentificationRequest |

try {
    final response = api.createIdentification(idempotencyKey, createIdentificationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FieldApi->createIdentification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |
 **createIdentificationRequest** | [**CreateIdentificationRequest**](CreateIdentificationRequest.md)|  |

### Return type

[**IdentificationJob**](IdentificationJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createMediaUpload**
> MediaUpload createMediaUpload(idempotencyKey, createUploadRequest)

Reserve a private media upload

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFieldApi();
final String idempotencyKey = idempotencyKey_example; // String |
final CreateUploadRequest createUploadRequest = ; // CreateUploadRequest |

try {
    final response = api.createMediaUpload(idempotencyKey, createUploadRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FieldApi->createMediaUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |
 **createUploadRequest** | [**CreateUploadRequest**](CreateUploadRequest.md)|  |

### Return type

[**MediaUpload**](MediaUpload.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getIdentification**
> IdentificationJob getIdentification(jobId)

Read a caller-owned identification job

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFieldApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getIdentification(jobId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FieldApi->getIdentification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |

### Return type

[**IdentificationJob**](IdentificationJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **retryIdentification**
> IdentificationJob retryIdentification(jobId, idempotencyKey)

Schedule a controlled identification retry

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFieldApi();
final String jobId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String idempotencyKey = idempotencyKey_example; // String |

try {
    final response = api.retryIdentification(jobId, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FieldApi->retryIdentification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **jobId** | **String**|  |
 **idempotencyKey** | **String**|  |

### Return type

[**IdentificationJob**](IdentificationJob.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadPrivateMediaContent**
> MediaUpload uploadPrivateMediaContent(mediaId, image)

Upload bytes to a caller-owned short-lived media reservation

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getFieldApi();
final String mediaId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final MultipartFile image = BINARY_DATA_HERE; // MultipartFile |

try {
    final response = api.uploadPrivateMediaContent(mediaId, image);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FieldApi->uploadPrivateMediaContent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mediaId** | **String**|  |
 **image** | **MultipartFile**|  |

### Return type

[**MediaUpload**](MediaUpload.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
