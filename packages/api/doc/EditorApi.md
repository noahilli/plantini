# openapi.api.EditorApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://127.0.0.1:1338/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**approveEditorChange**](EditorApi.md#approveeditorchange) | **POST** /editor/changes/{changeId}/approve | Approve a pending change editorially; release remains separate (reviewer role)
[**createEditorChange**](EditorApi.md#createeditorchange) | **POST** /editor/changes | Create a role-scoped editorial draft; does not publish
[**createEditorInvitation**](EditorApi.md#createeditorinvitation) | **POST** /editor/invitations | Invite an editor; only system administrators may invite reviewers
[**getEditorCatalog**](EditorApi.md#geteditorcatalog) | **GET** /editor/catalog | Read the editorial relationship tree (currently at most 1000 records per kind)
[**getEditorChange**](EditorApi.md#geteditorchange) | **GET** /editor/changes/{changeId} | Read an editorial change visible to the caller
[**getEditorDashboard**](EditorApi.md#geteditordashboard) | **GET** /editor/dashboard | Read role-scoped editorial counters
[**getEditorItem**](EditorApi.md#geteditoritem) | **GET** /editor/items/{type}/{itemId} | Read a published or draft CMS item as an editable payload
[**listEditorChanges**](EditorApi.md#listeditorchanges) | **GET** /editor/changes | List own drafts and reviews, or all changes for reviewers
[**rejectEditorChange**](EditorApi.md#rejecteditorchange) | **POST** /editor/changes/{changeId}/reject | Reject a pending change with a reason (reviewer role)
[**submitEditorChange**](EditorApi.md#submiteditorchange) | **POST** /editor/changes/{changeId}/submit | Submit own draft for botanical review
[**updateEditorChange**](EditorApi.md#updateeditorchange) | **PATCH** /editor/changes/{changeId} | Update own draft or rejected change; does not publish


# **approveEditorChange**
> EditorChange approveEditorChange(changeId, editorReviewRequest)

Approve a pending change editorially; release remains separate (reviewer role)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();
final String changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final EditorReviewRequest editorReviewRequest = ; // EditorReviewRequest |

try {
    final response = api.approveEditorChange(changeId, editorReviewRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->approveEditorChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeId** | **String**|  |
 **editorReviewRequest** | [**EditorReviewRequest**](EditorReviewRequest.md)|  | [optional]

### Return type

[**EditorChange**](EditorChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createEditorChange**
> EditorChange createEditorChange(editorSaveRequest)

Create a role-scoped editorial draft; does not publish

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();
final EditorSaveRequest editorSaveRequest = ; // EditorSaveRequest |

try {
    final response = api.createEditorChange(editorSaveRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->createEditorChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **editorSaveRequest** | [**EditorSaveRequest**](EditorSaveRequest.md)|  |

### Return type

[**EditorChange**](EditorChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createEditorInvitation**
> EditorInvitation createEditorInvitation(editorInvitationRequest)

Invite an editor; only system administrators may invite reviewers

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();
final EditorInvitationRequest editorInvitationRequest = ; // EditorInvitationRequest |

try {
    final response = api.createEditorInvitation(editorInvitationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->createEditorInvitation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **editorInvitationRequest** | [**EditorInvitationRequest**](EditorInvitationRequest.md)|  |

### Return type

[**EditorInvitation**](EditorInvitation.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEditorCatalog**
> EditorCatalog getEditorCatalog()

Read the editorial relationship tree (currently at most 1000 records per kind)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();

try {
    final response = api.getEditorCatalog();
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->getEditorCatalog: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**EditorCatalog**](EditorCatalog.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEditorChange**
> EditorChange getEditorChange(changeId)

Read an editorial change visible to the caller

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();
final String changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getEditorChange(changeId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->getEditorChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeId** | **String**|  |

### Return type

[**EditorChange**](EditorChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEditorDashboard**
> EditorDashboard getEditorDashboard()

Read role-scoped editorial counters

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();

try {
    final response = api.getEditorDashboard();
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->getEditorDashboard: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**EditorDashboard**](EditorDashboard.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getEditorItem**
> EditorItem getEditorItem(type, itemId)

Read a published or draft CMS item as an editable payload

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();
final String type = type_example; // String |
final String itemId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.getEditorItem(type, itemId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->getEditorItem: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **type** | **String**|  |
 **itemId** | **String**|  |

### Return type

[**EditorItem**](EditorItem.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listEditorChanges**
> BuiltList<EditorChange> listEditorChanges()

List own drafts and reviews, or all changes for reviewers

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();

try {
    final response = api.listEditorChanges();
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->listEditorChanges: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;EditorChange&gt;**](EditorChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rejectEditorChange**
> EditorChange rejectEditorChange(changeId, editorReviewRequest)

Reject a pending change with a reason (reviewer role)

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();
final String changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final EditorReviewRequest editorReviewRequest = ; // EditorReviewRequest |

try {
    final response = api.rejectEditorChange(changeId, editorReviewRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->rejectEditorChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeId** | **String**|  |
 **editorReviewRequest** | [**EditorReviewRequest**](EditorReviewRequest.md)|  |

### Return type

[**EditorChange**](EditorChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitEditorChange**
> EditorChange submitEditorChange(changeId)

Submit own draft for botanical review

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();
final String changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |

try {
    final response = api.submitEditorChange(changeId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->submitEditorChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeId** | **String**|  |

### Return type

[**EditorChange**](EditorChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateEditorChange**
> EditorChange updateEditorChange(changeId, editorSaveRequest)

Update own draft or rejected change; does not publish

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEditorApi();
final String changeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final EditorSaveRequest editorSaveRequest = ; // EditorSaveRequest |

try {
    final response = api.updateEditorChange(changeId, editorSaveRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EditorApi->updateEditorChange: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeId** | **String**|  |
 **editorSaveRequest** | [**EditorSaveRequest**](EditorSaveRequest.md)|  |

### Return type

[**EditorChange**](EditorChange.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
