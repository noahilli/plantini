# openapi.api.TeachingApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://127.0.0.1:1338/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createTeachingClass**](TeachingApi.md#createteachingclass) | **POST** /teaching/classes | Create an owned class
[**createTeachingStudent**](TeachingApi.md#createteachingstudent) | **POST** /teaching/classes/{classId}/students | Create a managed learner in an owned class
[**getTeachingClass**](TeachingApi.md#getteachingclass) | **GET** /teaching/classes/{classId} | Read an owned class and student progress
[**getTeachingDashboard**](TeachingApi.md#getteachingdashboard) | **GET** /teaching/dashboard | Read progress across owned classes
[**getTeachingSession**](TeachingApi.md#getteachingsession) | **GET** /teaching/session | Read the authenticated teaching session
[**listTeachingClasses**](TeachingApi.md#listteachingclasses) | **GET** /teaching/classes | List owned classes
[**resetTeachingStudentPassword**](TeachingApi.md#resetteachingstudentpassword) | **POST** /teaching/students/{studentId}/reset-password | Reset a managed learner password
[**updateTeachingStudent**](TeachingApi.md#updateteachingstudent) | **PATCH** /teaching/students/{studentId} | Enable or disable an owned managed learner


# **createTeachingClass**
> TeachingClass createTeachingClass(teachingCreateClassRequest)

Create an owned class

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTeachingApi();
final TeachingCreateClassRequest teachingCreateClassRequest = ; // TeachingCreateClassRequest |

try {
    final response = api.createTeachingClass(teachingCreateClassRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TeachingApi->createTeachingClass: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **teachingCreateClassRequest** | [**TeachingCreateClassRequest**](TeachingCreateClassRequest.md)|  |

### Return type

[**TeachingClass**](TeachingClass.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTeachingStudent**
> TeachingCreateStudentResponse createTeachingStudent(classId, teachingCreateStudentRequest)

Create a managed learner in an owned class

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTeachingApi();
final String classId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final TeachingCreateStudentRequest teachingCreateStudentRequest = ; // TeachingCreateStudentRequest |

try {
    final response = api.createTeachingStudent(classId, teachingCreateStudentRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TeachingApi->createTeachingStudent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **classId** | **String**|  |
 **teachingCreateStudentRequest** | [**TeachingCreateStudentRequest**](TeachingCreateStudentRequest.md)|  |

### Return type

[**TeachingCreateStudentResponse**](TeachingCreateStudentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTeachingClass**
> TeachingClassDetail getTeachingClass(classId)

Read an owned class and student progress

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTeachingApi();
final String classId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getTeachingClass(classId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TeachingApi->getTeachingClass: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **classId** | **String**|  |

### Return type

[**TeachingClassDetail**](TeachingClassDetail.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTeachingDashboard**
> TeachingDashboard getTeachingDashboard()

Read progress across owned classes

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTeachingApi();

try {
    final response = api.getTeachingDashboard();
    print(response);
} on DioException catch (e) {
    print('Exception when calling TeachingApi->getTeachingDashboard: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**TeachingDashboard**](TeachingDashboard.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTeachingSession**
> TeachingSession getTeachingSession()

Read the authenticated teaching session

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTeachingApi();

try {
    final response = api.getTeachingSession();
    print(response);
} on DioException catch (e) {
    print('Exception when calling TeachingApi->getTeachingSession: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**TeachingSession**](TeachingSession.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTeachingClasses**
> TeachingClassList listTeachingClasses()

List owned classes

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTeachingApi();

try {
    final response = api.listTeachingClasses();
    print(response);
} on DioException catch (e) {
    print('Exception when calling TeachingApi->listTeachingClasses: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**TeachingClassList**](TeachingClassList.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetTeachingStudentPassword**
> TeachingResetPasswordResponse resetTeachingStudentPassword(studentId)

Reset a managed learner password

No request body is needed. An empty JSON object is accepted for compatibility; any fields or non-object bodies are rejected with 400.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTeachingApi();
final String studentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.resetTeachingStudentPassword(studentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TeachingApi->resetTeachingStudentPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **studentId** | **String**|  |

### Return type

[**TeachingResetPasswordResponse**](TeachingResetPasswordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTeachingStudent**
> TeachingUpdateStudentResponse updateTeachingStudent(studentId, teachingUpdateStudentRequest)

Enable or disable an owned managed learner

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getTeachingApi();
final String studentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final TeachingUpdateStudentRequest teachingUpdateStudentRequest = ; // TeachingUpdateStudentRequest |

try {
    final response = api.updateTeachingStudent(studentId, teachingUpdateStudentRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TeachingApi->updateTeachingStudent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **studentId** | **String**|  |
 **teachingUpdateStudentRequest** | [**TeachingUpdateStudentRequest**](TeachingUpdateStudentRequest.md)|  |

### Return type

[**TeachingUpdateStudentResponse**](TeachingUpdateStudentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
