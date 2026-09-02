# openapi.api.LearningApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://127.0.0.1:1338/api/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**completeLevelAttempt**](LearningApi.md#completelevelattempt) | **POST** /level-attempts/{attemptId}/complete | Complete an attempt with server-side scoring
[**getProgress**](LearningApi.md#getprogress) | **GET** /progress | Read server-authoritative learning progress
[**listAchievements**](LearningApi.md#listachievements) | **GET** /achievements | List earned and next learning achievements
[**listQuizItems**](LearningApi.md#listquizitems) | **GET** /quiz-items | List quiz items for a level and content version
[**startLevelAttempt**](LearningApi.md#startlevelattempt) | **POST** /level-attempts | Start or resume an idempotent level attempt
[**submitLearningEvents**](LearningApi.md#submitlearningevents) | **POST** /learning-events/batch | Submit idempotent offline learning events
[**synchronize**](LearningApi.md#synchronize) | **POST** /sync | Synchronize a bounded offline event batch and progress cursor


# **completeLevelAttempt**
> LevelCompletion completeLevelAttempt(attemptId, idempotencyKey, completeLevelAttemptRequest)

Complete an attempt with server-side scoring

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLearningApi();
final String attemptId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String idempotencyKey = idempotencyKey_example; // String |
final CompleteLevelAttemptRequest completeLevelAttemptRequest = ; // CompleteLevelAttemptRequest |

try {
    final response = api.completeLevelAttempt(attemptId, idempotencyKey, completeLevelAttemptRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearningApi->completeLevelAttempt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **attemptId** | **String**|  |
 **idempotencyKey** | **String**|  |
 **completeLevelAttemptRequest** | [**CompleteLevelAttemptRequest**](CompleteLevelAttemptRequest.md)|  |

### Return type

[**LevelCompletion**](LevelCompletion.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProgress**
> ProgressSnapshot getProgress(since)

Read server-authoritative learning progress

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLearningApi();
final DateTime since = 2013-10-20T19:20:30+01:00; // DateTime |

try {
    final response = api.getProgress(since);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearningApi->getProgress: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **since** | **DateTime**|  | [optional]

### Return type

[**ProgressSnapshot**](ProgressSnapshot.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAchievements**
> AchievementPage listAchievements()

List earned and next learning achievements

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLearningApi();

try {
    final response = api.listAchievements();
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearningApi->listAchievements: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AchievementPage**](AchievementPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listQuizItems**
> QuizItemPage listQuizItems(levelId, contentVersion)

List quiz items for a level and content version

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLearningApi();
final String levelId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String |
final String contentVersion = contentVersion_example; // String |

try {
    final response = api.listQuizItems(levelId, contentVersion);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearningApi->listQuizItems: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **levelId** | **String**|  |
 **contentVersion** | **String**|  | [optional]

### Return type

[**QuizItemPage**](QuizItemPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startLevelAttempt**
> LevelAttempt startLevelAttempt(idempotencyKey, startLevelAttemptRequest)

Start or resume an idempotent level attempt

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLearningApi();
final String idempotencyKey = idempotencyKey_example; // String |
final StartLevelAttemptRequest startLevelAttemptRequest = ; // StartLevelAttemptRequest |

try {
    final response = api.startLevelAttempt(idempotencyKey, startLevelAttemptRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearningApi->startLevelAttempt: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |
 **startLevelAttemptRequest** | [**StartLevelAttemptRequest**](StartLevelAttemptRequest.md)|  |

### Return type

[**LevelAttempt**](LevelAttempt.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitLearningEvents**
> EventBatchAck submitLearningEvents(idempotencyKey, learningEventBatch)

Submit idempotent offline learning events

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLearningApi();
final String idempotencyKey = idempotencyKey_example; // String |
final LearningEventBatch learningEventBatch = ; // LearningEventBatch |

try {
    final response = api.submitLearningEvents(idempotencyKey, learningEventBatch);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearningApi->submitLearningEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |
 **learningEventBatch** | [**LearningEventBatch**](LearningEventBatch.md)|  |

### Return type

[**EventBatchAck**](EventBatchAck.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **synchronize**
> SyncResponse synchronize(idempotencyKey, syncRequest)

Synchronize a bounded offline event batch and progress cursor

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getLearningApi();
final String idempotencyKey = idempotencyKey_example; // String |
final SyncRequest syncRequest = ; // SyncRequest |

try {
    final response = api.synchronize(idempotencyKey, syncRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LearningApi->synchronize: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**|  |
 **syncRequest** | [**SyncRequest**](SyncRequest.md)|  |

### Return type

[**SyncResponse**](SyncResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
