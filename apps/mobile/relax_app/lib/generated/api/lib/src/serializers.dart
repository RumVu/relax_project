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
import 'package:relax_api_client/src/date_serializer.dart';
import 'package:relax_api_client/src/model/date.dart';

import 'package:relax_api_client/src/model/admin_log_actor_dto.dart';
import 'package:relax_api_client/src/model/admin_log_page_dto.dart';
import 'package:relax_api_client/src/model/admin_log_response_dto.dart';
import 'package:relax_api_client/src/model/ambient_sound_page_dto.dart';
import 'package:relax_api_client/src/model/ambient_sound_response_dto.dart';
import 'package:relax_api_client/src/model/app_theme_page_dto.dart';
import 'package:relax_api_client/src/model/app_theme_response_dto.dart';
import 'package:relax_api_client/src/model/auth_action_result_dto.dart';
import 'package:relax_api_client/src/model/auth_response_dto.dart';
import 'package:relax_api_client/src/model/billing_me_response_dto.dart';
import 'package:relax_api_client/src/model/billing_plan_limit_dto.dart';
import 'package:relax_api_client/src/model/billing_plan_response_dto.dart';
import 'package:relax_api_client/src/model/breathing_exercise_page_dto.dart';
import 'package:relax_api_client/src/model/breathing_exercise_response_dto.dart';
import 'package:relax_api_client/src/model/change_password_dto.dart';
import 'package:relax_api_client/src/model/check_content_dto.dart';
import 'package:relax_api_client/src/model/checkout_resolved_plan_dto.dart';
import 'package:relax_api_client/src/model/checkout_session_response_dto.dart';
import 'package:relax_api_client/src/model/checkout_session_status_dto.dart';
import 'package:relax_api_client/src/model/companion_asset_page_dto.dart';
import 'package:relax_api_client/src/model/companion_asset_response_dto.dart';
import 'package:relax_api_client/src/model/companion_chat_dto.dart';
import 'package:relax_api_client/src/model/companion_message_page_dto.dart';
import 'package:relax_api_client/src/model/companion_message_response_dto.dart';
import 'package:relax_api_client/src/model/confirm_payment_dto.dart';
import 'package:relax_api_client/src/model/confirm_payment_plan_dto.dart';
import 'package:relax_api_client/src/model/confirm_payment_response_dto.dart';
import 'package:relax_api_client/src/model/cozy_quote_page_dto.dart';
import 'package:relax_api_client/src/model/cozy_quote_response_dto.dart';
import 'package:relax_api_client/src/model/create_ambient_sound_dto.dart';
import 'package:relax_api_client/src/model/create_app_theme_dto.dart';
import 'package:relax_api_client/src/model/create_breathing_exercise_dto.dart';
import 'package:relax_api_client/src/model/create_checkout_session_dto.dart';
import 'package:relax_api_client/src/model/create_companion_asset_dto.dart';
import 'package:relax_api_client/src/model/create_companion_interaction_dto.dart';
import 'package:relax_api_client/src/model/create_companion_message_dto.dart';
import 'package:relax_api_client/src/model/create_cozy_quote_dto.dart';
import 'package:relax_api_client/src/model/create_experiment_dto.dart';
import 'package:relax_api_client/src/model/create_journal_dto.dart';
import 'package:relax_api_client/src/model/create_meditation_session_dto.dart';
import 'package:relax_api_client/src/model/create_mood_checkin_dto.dart';
import 'package:relax_api_client/src/model/create_notification_dto.dart';
import 'package:relax_api_client/src/model/create_onboarding_slide_dto.dart';
import 'package:relax_api_client/src/model/create_reminder_dto.dart';
import 'package:relax_api_client/src/model/create_signed_upload_url_dto.dart';
import 'package:relax_api_client/src/model/create_sleep_session_dto.dart';
import 'package:relax_api_client/src/model/create_tier_dto.dart';
import 'package:relax_api_client/src/model/create_user_dto.dart';
import 'package:relax_api_client/src/model/delete_account_dto.dart';
import 'package:relax_api_client/src/model/demo_login_dto.dart';
import 'package:relax_api_client/src/model/error_response.dart';
import 'package:relax_api_client/src/model/feedback_insight_dto.dart';
import 'package:relax_api_client/src/model/finish_relax_session_dto.dart';
import 'package:relax_api_client/src/model/google_login_dto.dart';
import 'package:relax_api_client/src/model/journal_page_dto.dart';
import 'package:relax_api_client/src/model/journal_response_dto.dart';
import 'package:relax_api_client/src/model/log_experiment_event_dto.dart';
import 'package:relax_api_client/src/model/login_dto.dart';
import 'package:relax_api_client/src/model/mood_checkin_page_dto.dart';
import 'package:relax_api_client/src/model/mood_checkin_response_dto.dart';
import 'package:relax_api_client/src/model/notification_page_dto.dart';
import 'package:relax_api_client/src/model/notification_response_dto.dart';
import 'package:relax_api_client/src/model/onboarding_slide_page_dto.dart';
import 'package:relax_api_client/src/model/onboarding_slide_response_dto.dart';
import 'package:relax_api_client/src/model/payment_response_dto.dart';
import 'package:relax_api_client/src/model/provider_status_response_dto.dart';
import 'package:relax_api_client/src/model/push_device_response_dto.dart';
import 'package:relax_api_client/src/model/rate_content_dto.dart';
import 'package:relax_api_client/src/model/recalculate_weekly_mood_stats_dto.dart';
import 'package:relax_api_client/src/model/refresh_token_dto.dart';
import 'package:relax_api_client/src/model/register_dto.dart';
import 'package:relax_api_client/src/model/register_push_device_dto.dart';
import 'package:relax_api_client/src/model/register_storage_file_dto.dart';
import 'package:relax_api_client/src/model/relax_session_page_dto.dart';
import 'package:relax_api_client/src/model/relax_session_response_dto.dart';
import 'package:relax_api_client/src/model/reminder_page_dto.dart';
import 'package:relax_api_client/src/model/reminder_response_dto.dart';
import 'package:relax_api_client/src/model/remove_storage_object_dto.dart';
import 'package:relax_api_client/src/model/request_password_reset_dto.dart';
import 'package:relax_api_client/src/model/reset_password_dto.dart';
import 'package:relax_api_client/src/model/run_weekly_mood_stats_job_dto.dart';
import 'package:relax_api_client/src/model/session_response_dto.dart';
import 'package:relax_api_client/src/model/set_user_plan_dto.dart';
import 'package:relax_api_client/src/model/start_relax_session_dto.dart';
import 'package:relax_api_client/src/model/storage_file_response_dto.dart';
import 'package:relax_api_client/src/model/subscription_response_dto.dart';
import 'package:relax_api_client/src/model/switch_companion_personalization_dto.dart';
import 'package:relax_api_client/src/model/tier_name_dto.dart';
import 'package:relax_api_client/src/model/unread_count_response_dto.dart';
import 'package:relax_api_client/src/model/update_ambient_sound_dto.dart';
import 'package:relax_api_client/src/model/update_app_theme_dto.dart';
import 'package:relax_api_client/src/model/update_breathing_exercise_dto.dart';
import 'package:relax_api_client/src/model/update_companion_asset_dto.dart';
import 'package:relax_api_client/src/model/update_companion_message_dto.dart';
import 'package:relax_api_client/src/model/update_cozy_quote_dto.dart';
import 'package:relax_api_client/src/model/update_experiment_dto.dart';
import 'package:relax_api_client/src/model/update_journal_dto.dart';
import 'package:relax_api_client/src/model/update_mood_checkin_dto.dart';
import 'package:relax_api_client/src/model/update_onboarding_slide_dto.dart';
import 'package:relax_api_client/src/model/update_reminder_dto.dart';
import 'package:relax_api_client/src/model/update_tier_dto.dart';
import 'package:relax_api_client/src/model/update_user_dto.dart';
import 'package:relax_api_client/src/model/update_weather_location_dto.dart';
import 'package:relax_api_client/src/model/upsert_feature_flag_dto.dart';
import 'package:relax_api_client/src/model/upsert_user_companion_dto.dart';
import 'package:relax_api_client/src/model/upsert_user_preference_dto.dart';
import 'package:relax_api_client/src/model/upsert_user_profile_dto.dart';
import 'package:relax_api_client/src/model/user_companion_response_dto.dart';
import 'package:relax_api_client/src/model/user_page_dto.dart';
import 'package:relax_api_client/src/model/user_preference_response_dto.dart';
import 'package:relax_api_client/src/model/user_profile_response_dto.dart';
import 'package:relax_api_client/src/model/user_response_dto.dart';
import 'package:relax_api_client/src/model/user_subscription_summary_dto.dart';
import 'package:relax_api_client/src/model/verify_email_dto.dart';
import 'package:relax_api_client/src/model/weather_current_data_dto.dart';
import 'package:relax_api_client/src/model/weather_current_response_dto.dart';
import 'package:relax_api_client/src/model/weather_forecast_day_dto.dart';
import 'package:relax_api_client/src/model/weather_forecast_response_dto.dart';
import 'package:relax_api_client/src/model/weather_greeting_dto.dart';
import 'package:relax_api_client/src/model/weather_location_dto.dart';
import 'package:relax_api_client/src/model/weekly_mood_stat_response_dto.dart';

part 'serializers.g.dart';

@SerializersFor([
  AdminLogActorDto,
  AdminLogPageDto,
  AdminLogResponseDto,
  AmbientSoundPageDto,
  AmbientSoundResponseDto,
  AppThemePageDto,
  AppThemeResponseDto,
  AuthActionResultDto,
  AuthResponseDto,
  BillingMeResponseDto,
  BillingPlanLimitDto,
  BillingPlanResponseDto,
  BreathingExercisePageDto,
  BreathingExerciseResponseDto,
  ChangePasswordDto,
  CheckContentDto,
  CheckoutResolvedPlanDto,
  CheckoutSessionResponseDto,
  CheckoutSessionStatusDto,
  CompanionAssetPageDto,
  CompanionAssetResponseDto,
  CompanionChatDto,
  CompanionMessagePageDto,
  CompanionMessageResponseDto,
  ConfirmPaymentDto,
  ConfirmPaymentPlanDto,
  ConfirmPaymentResponseDto,
  CozyQuotePageDto,
  CozyQuoteResponseDto,
  CreateAmbientSoundDto,
  CreateAppThemeDto,
  CreateBreathingExerciseDto,
  CreateCheckoutSessionDto,
  CreateCompanionAssetDto,
  CreateCompanionInteractionDto,
  CreateCompanionMessageDto,
  CreateCozyQuoteDto,
  CreateExperimentDto,
  CreateJournalDto,
  CreateMeditationSessionDto,
  CreateMoodCheckinDto,
  CreateNotificationDto,
  CreateOnboardingSlideDto,
  CreateReminderDto,
  CreateSignedUploadUrlDto,
  CreateSleepSessionDto,
  CreateTierDto,
  CreateUserDto,
  DeleteAccountDto,
  DemoLoginDto,
  ErrorResponse,
  FeedbackInsightDto,
  FinishRelaxSessionDto,
  GoogleLoginDto,
  JournalPageDto,
  JournalResponseDto,
  LogExperimentEventDto,
  LoginDto,
  MoodCheckinPageDto,
  MoodCheckinResponseDto,
  NotificationPageDto,
  NotificationResponseDto,
  OnboardingSlidePageDto,
  OnboardingSlideResponseDto,
  PaymentResponseDto,
  ProviderStatusResponseDto,
  PushDeviceResponseDto,
  RateContentDto,
  RecalculateWeeklyMoodStatsDto,
  RefreshTokenDto,
  RegisterDto,
  RegisterPushDeviceDto,
  RegisterStorageFileDto,
  RelaxSessionPageDto,
  RelaxSessionResponseDto,
  ReminderPageDto,
  ReminderResponseDto,
  RemoveStorageObjectDto,
  RequestPasswordResetDto,
  ResetPasswordDto,
  RunWeeklyMoodStatsJobDto,
  SessionResponseDto,
  SetUserPlanDto,
  StartRelaxSessionDto,
  StorageFileResponseDto,
  SubscriptionResponseDto,
  SwitchCompanionPersonalizationDto,
  TierNameDto,
  UnreadCountResponseDto,
  UpdateAmbientSoundDto,
  UpdateAppThemeDto,
  UpdateBreathingExerciseDto,
  UpdateCompanionAssetDto,
  UpdateCompanionMessageDto,
  UpdateCozyQuoteDto,
  UpdateExperimentDto,
  UpdateJournalDto,
  UpdateMoodCheckinDto,
  UpdateOnboardingSlideDto,
  UpdateReminderDto,
  UpdateTierDto,
  UpdateUserDto,
  UpdateWeatherLocationDto,
  UpsertFeatureFlagDto,
  UpsertUserCompanionDto,
  UpsertUserPreferenceDto,
  UpsertUserProfileDto,
  UserCompanionResponseDto,
  UserPageDto,
  UserPreferenceResponseDto,
  UserProfileResponseDto,
  UserResponseDto,
  UserSubscriptionSummaryDto,
  VerifyEmailDto,
  WeatherCurrentDataDto,
  WeatherCurrentResponseDto,
  WeatherForecastDayDto,
  WeatherForecastResponseDto,
  WeatherGreetingDto,
  WeatherLocationDto,
  WeeklyMoodStatResponseDto,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(BillingPlanResponseDto)]),
        () => ListBuilder<BillingPlanResponseDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(WeeklyMoodStatResponseDto)]),
        () => ListBuilder<WeeklyMoodStatResponseDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(AmbientSoundResponseDto)]),
        () => ListBuilder<AmbientSoundResponseDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CozyQuoteResponseDto)]),
        () => ListBuilder<CozyQuoteResponseDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PushDeviceResponseDto)]),
        () => ListBuilder<PushDeviceResponseDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(JsonObject)]),
        () => ListBuilder<JsonObject>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SessionResponseDto)]),
        () => ListBuilder<SessionResponseDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(StorageFileResponseDto)]),
        () => ListBuilder<StorageFileResponseDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
