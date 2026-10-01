//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/achievement.dart';
import 'package:openapi/src/model/achievement_page.dart';
import 'package:openapi/src/model/admin_dashboard.dart';
import 'package:openapi/src/model/admin_user.dart';
import 'package:openapi/src/model/admin_user_page.dart';
import 'package:openapi/src/model/administrative_job.dart';
import 'package:openapi/src/model/character.dart';
import 'package:openapi/src/model/collection_share.dart';
import 'package:openapi/src/model/collection_stats.dart';
import 'package:openapi/src/model/complete_level_attempt_request.dart';
import 'package:openapi/src/model/completion_rule.dart';
import 'package:openapi/src/model/confirm_identification_request.dart';
import 'package:openapi/src/model/content_change.dart';
import 'package:openapi/src/model/content_change_page.dart';
import 'package:openapi/src/model/content_manifest.dart';
import 'package:openapi/src/model/content_package.dart';
import 'package:openapi/src/model/create_content_release_request.dart';
import 'package:openapi/src/model/create_identification_request.dart';
import 'package:openapi/src/model/create_import_request.dart';
import 'package:openapi/src/model/create_observation_request.dart';
import 'package:openapi/src/model/create_upload_request.dart';
import 'package:openapi/src/model/ecosystem.dart';
import 'package:openapi/src/model/ecosystem_page.dart';
import 'package:openapi/src/model/ecosystem_progress.dart';
import 'package:openapi/src/model/event_batch_ack.dart';
import 'package:openapi/src/model/identification_candidate.dart';
import 'package:openapi/src/model/identification_job.dart';
import 'package:openapi/src/model/identification_provider_metadata.dart';
import 'package:openapi/src/model/learning_event.dart';
import 'package:openapi/src/model/learning_event_batch.dart';
import 'package:openapi/src/model/level.dart';
import 'package:openapi/src/model/level_attempt.dart';
import 'package:openapi/src/model/level_completion.dart';
import 'package:openapi/src/model/level_progress.dart';
import 'package:openapi/src/model/media_upload.dart';
import 'package:openapi/src/model/observation.dart';
import 'package:openapi/src/model/observation_location.dart';
import 'package:openapi/src/model/observation_page.dart';
import 'package:openapi/src/model/page_meta.dart';
import 'package:openapi/src/model/plant.dart';
import 'package:openapi/src/model/plant_profile_cards_inner.dart';
import 'package:openapi/src/model/private_location.dart';
import 'package:openapi/src/model/problem.dart';
import 'package:openapi/src/model/progress_snapshot.dart';
import 'package:openapi/src/model/public_media.dart';
import 'package:openapi/src/model/quiz_answer.dart';
import 'package:openapi/src/model/quiz_choice.dart';
import 'package:openapi/src/model/quiz_item.dart';
import 'package:openapi/src/model/quiz_item_page.dart';
import 'package:openapi/src/model/species_card.dart';
import 'package:openapi/src/model/start_level_attempt_request.dart';
import 'package:openapi/src/model/sync_request.dart';
import 'package:openapi/src/model/sync_response.dart';
import 'package:openapi/src/model/update_observation_request.dart';
import 'package:openapi/src/model/update_profile_request.dart';
import 'package:openapi/src/model/user_profile.dart';

part 'serializers.g.dart';

@SerializersFor([
  Achievement,
  AchievementPage,
  AdminDashboard,
  AdminUser,
  AdminUserPage,
  AdministrativeJob,
  Character,
  CollectionShare,
  CollectionStats,
  CompleteLevelAttemptRequest,
  CompletionRule,
  ConfirmIdentificationRequest,
  ContentChange,
  ContentChangePage,
  ContentManifest,
  ContentPackage,
  CreateContentReleaseRequest,
  CreateIdentificationRequest,
  CreateImportRequest,
  CreateObservationRequest,
  CreateUploadRequest,
  Ecosystem,
  EcosystemPage,
  EcosystemProgress,
  EventBatchAck,
  IdentificationCandidate,
  IdentificationJob,
  IdentificationProviderMetadata,
  LearningEvent,
  LearningEventBatch,
  Level,
  LevelAttempt,
  LevelCompletion,
  LevelProgress,
  MediaUpload,
  Observation,
  ObservationLocation,
  ObservationPage,
  PageMeta,
  Plant,
  PlantProfileCardsInner,
  PrivateLocation,
  Problem,
  ProgressSnapshot,
  PublicMedia,
  QuizAnswer,
  QuizChoice,
  QuizItem,
  QuizItemPage,
  SpeciesCard,
  StartLevelAttemptRequest,
  SyncRequest,
  SyncResponse,
  UpdateObservationRequest,
  UpdateProfileRequest,
  UserProfile,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(String)]),
        () => MapBuilder<String, String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(LevelProgress)]),
        () => ListBuilder<LevelProgress>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltSet, [FullType(String)]),
        () => SetBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(IdentificationCandidate)]),
        () => ListBuilder<IdentificationCandidate>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ContentChange)]),
        () => ListBuilder<ContentChange>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Ecosystem)]),
        () => ListBuilder<Ecosystem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(num)]),
        () => MapBuilder<String, num>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(AdminUser)]),
        () => ListBuilder<AdminUser>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(QuizAnswer)]),
        () => ListBuilder<QuizAnswer>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ContentPackage)]),
        () => ListBuilder<ContentPackage>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(CollectionShare)]),
        () => MapBuilder<String, CollectionShare>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlantProfileCardsInner)]),
        () => ListBuilder<PlantProfileCardsInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Observation)]),
        () => ListBuilder<Observation>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PublicMedia)]),
        () => ListBuilder<PublicMedia>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(QuizChoice)]),
        () => ListBuilder<QuizChoice>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(LearningEvent)]),
        () => ListBuilder<LearningEvent>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Achievement)]),
        () => ListBuilder<Achievement>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Problem)]),
        () => ListBuilder<Problem>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(QuizItem)]),
        () => ListBuilder<QuizItem>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
