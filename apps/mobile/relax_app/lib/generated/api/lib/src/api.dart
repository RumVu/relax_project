//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:relax_api_client/src/serializers.dart';
import 'package:relax_api_client/src/auth/api_key_auth.dart';
import 'package:relax_api_client/src/auth/basic_auth.dart';
import 'package:relax_api_client/src/auth/bearer_auth.dart';
import 'package:relax_api_client/src/auth/oauth.dart';
import 'package:relax_api_client/src/api/achievements_api.dart';
import 'package:relax_api_client/src/api/admin_dashboard_api.dart';
import 'package:relax_api_client/src/api/admin_logs_api.dart';
import 'package:relax_api_client/src/api/admin_pricing_api.dart';
import 'package:relax_api_client/src/api/admin_users_api.dart';
import 'package:relax_api_client/src/api/ai_insights_api.dart';
import 'package:relax_api_client/src/api/ambient_sounds_api.dart';
import 'package:relax_api_client/src/api/analytics_api.dart';
import 'package:relax_api_client/src/api/app_themes_api.dart';
import 'package:relax_api_client/src/api/auth_api.dart';
import 'package:relax_api_client/src/api/billing_api.dart';
import 'package:relax_api_client/src/api/breathing_exercises_api.dart';
import 'package:relax_api_client/src/api/companion_assets_api.dart';
import 'package:relax_api_client/src/api/companion_messages_api.dart';
import 'package:relax_api_client/src/api/cozy_quotes_api.dart';
import 'package:relax_api_client/src/api/crisis_api.dart';
import 'package:relax_api_client/src/api/experiments_api.dart';
import 'package:relax_api_client/src/api/feature_flags_api.dart';
import 'package:relax_api_client/src/api/feed_api.dart';
import 'package:relax_api_client/src/api/friends_api.dart';
import 'package:relax_api_client/src/api/health_api.dart';
import 'package:relax_api_client/src/api/jobs_api.dart';
import 'package:relax_api_client/src/api/journals_api.dart';
import 'package:relax_api_client/src/api/meditations_api.dart';
import 'package:relax_api_client/src/api/mood_check_ins_api.dart';
import 'package:relax_api_client/src/api/notifications_api.dart';
import 'package:relax_api_client/src/api/onboarding_slides_api.dart';
import 'package:relax_api_client/src/api/quests_api.dart';
import 'package:relax_api_client/src/api/queues_api.dart';
import 'package:relax_api_client/src/api/realtime_api.dart';
import 'package:relax_api_client/src/api/recommendations_api.dart';
import 'package:relax_api_client/src/api/redis_api.dart';
import 'package:relax_api_client/src/api/relax_activities_api.dart';
import 'package:relax_api_client/src/api/relax_sessions_api.dart';
import 'package:relax_api_client/src/api/reminders_api.dart';
import 'package:relax_api_client/src/api/sessions_api.dart';
import 'package:relax_api_client/src/api/sleep_api.dart';
import 'package:relax_api_client/src/api/storage_api.dart';
import 'package:relax_api_client/src/api/user_companions_api.dart';
import 'package:relax_api_client/src/api/user_preferences_api.dart';
import 'package:relax_api_client/src/api/user_profiles_api.dart';
import 'package:relax_api_client/src/api/users_api.dart';
import 'package:relax_api_client/src/api/weather_api.dart';

class RelaxApiClient {
  static const String basePath = r'http://localhost';

  final Dio dio;
  final Serializers serializers;

  RelaxApiClient({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the OAuth token associated with the given [name].
  ///
  /// If no [OAuthInterceptor] is registered or no token exists for the given
  /// [name], this method has no effect.
  void removeOAuthToken(String name) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens.remove(name);
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the bearer authentication token associated with the given [name].
  ///
  /// If no [BearerAuthInterceptor] is registered or no token exists for the
  /// given [name], this method has no effect.
  void removeBearerAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens.remove(name);
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  /// Removes the basic authentication credentials associated with the given [name].
  ///
  /// If no [BasicAuthInterceptor] is registered or no credentials exist for the
  /// given [name], this method has no effect.
  void removeBasicAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo.remove(name);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Removes the API key associated with the given [name].
  ///
  /// If no [ApiKeyAuthInterceptor] is registered or no API key exists for the
  /// given [name], this method has no effect.
  void removeApiKey(String name) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys.remove(name);
    }
  }

  /// Get AchievementsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AchievementsApi getAchievementsApi() {
    return AchievementsApi(dio, serializers);
  }

  /// Get AdminDashboardApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminDashboardApi getAdminDashboardApi() {
    return AdminDashboardApi(dio, serializers);
  }

  /// Get AdminLogsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminLogsApi getAdminLogsApi() {
    return AdminLogsApi(dio, serializers);
  }

  /// Get AdminPricingApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminPricingApi getAdminPricingApi() {
    return AdminPricingApi(dio, serializers);
  }

  /// Get AdminUsersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminUsersApi getAdminUsersApi() {
    return AdminUsersApi(dio, serializers);
  }

  /// Get AiInsightsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AiInsightsApi getAiInsightsApi() {
    return AiInsightsApi(dio, serializers);
  }

  /// Get AmbientSoundsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AmbientSoundsApi getAmbientSoundsApi() {
    return AmbientSoundsApi(dio, serializers);
  }

  /// Get AnalyticsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AnalyticsApi getAnalyticsApi() {
    return AnalyticsApi(dio, serializers);
  }

  /// Get AppThemesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AppThemesApi getAppThemesApi() {
    return AppThemesApi(dio, serializers);
  }

  /// Get AuthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuthApi getAuthApi() {
    return AuthApi(dio, serializers);
  }

  /// Get BillingApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BillingApi getBillingApi() {
    return BillingApi(dio, serializers);
  }

  /// Get BreathingExercisesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BreathingExercisesApi getBreathingExercisesApi() {
    return BreathingExercisesApi(dio, serializers);
  }

  /// Get CompanionAssetsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CompanionAssetsApi getCompanionAssetsApi() {
    return CompanionAssetsApi(dio, serializers);
  }

  /// Get CompanionMessagesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CompanionMessagesApi getCompanionMessagesApi() {
    return CompanionMessagesApi(dio, serializers);
  }

  /// Get CozyQuotesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CozyQuotesApi getCozyQuotesApi() {
    return CozyQuotesApi(dio, serializers);
  }

  /// Get CrisisApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CrisisApi getCrisisApi() {
    return CrisisApi(dio, serializers);
  }

  /// Get ExperimentsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ExperimentsApi getExperimentsApi() {
    return ExperimentsApi(dio, serializers);
  }

  /// Get FeatureFlagsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  FeatureFlagsApi getFeatureFlagsApi() {
    return FeatureFlagsApi(dio, serializers);
  }

  /// Get FeedApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  FeedApi getFeedApi() {
    return FeedApi(dio, serializers);
  }

  /// Get FriendsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  FriendsApi getFriendsApi() {
    return FriendsApi(dio, serializers);
  }

  /// Get HealthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  HealthApi getHealthApi() {
    return HealthApi(dio, serializers);
  }

  /// Get JobsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  JobsApi getJobsApi() {
    return JobsApi(dio, serializers);
  }

  /// Get JournalsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  JournalsApi getJournalsApi() {
    return JournalsApi(dio, serializers);
  }

  /// Get MeditationsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MeditationsApi getMeditationsApi() {
    return MeditationsApi(dio, serializers);
  }

  /// Get MoodCheckInsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MoodCheckInsApi getMoodCheckInsApi() {
    return MoodCheckInsApi(dio, serializers);
  }

  /// Get NotificationsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  NotificationsApi getNotificationsApi() {
    return NotificationsApi(dio, serializers);
  }

  /// Get OnboardingSlidesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  OnboardingSlidesApi getOnboardingSlidesApi() {
    return OnboardingSlidesApi(dio, serializers);
  }

  /// Get QuestsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  QuestsApi getQuestsApi() {
    return QuestsApi(dio, serializers);
  }

  /// Get QueuesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  QueuesApi getQueuesApi() {
    return QueuesApi(dio, serializers);
  }

  /// Get RealtimeApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RealtimeApi getRealtimeApi() {
    return RealtimeApi(dio, serializers);
  }

  /// Get RecommendationsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RecommendationsApi getRecommendationsApi() {
    return RecommendationsApi(dio, serializers);
  }

  /// Get RedisApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RedisApi getRedisApi() {
    return RedisApi(dio, serializers);
  }

  /// Get RelaxActivitiesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RelaxActivitiesApi getRelaxActivitiesApi() {
    return RelaxActivitiesApi(dio, serializers);
  }

  /// Get RelaxSessionsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RelaxSessionsApi getRelaxSessionsApi() {
    return RelaxSessionsApi(dio, serializers);
  }

  /// Get RemindersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RemindersApi getRemindersApi() {
    return RemindersApi(dio, serializers);
  }

  /// Get SessionsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SessionsApi getSessionsApi() {
    return SessionsApi(dio, serializers);
  }

  /// Get SleepApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SleepApi getSleepApi() {
    return SleepApi(dio, serializers);
  }

  /// Get StorageApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  StorageApi getStorageApi() {
    return StorageApi(dio, serializers);
  }

  /// Get UserCompanionsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UserCompanionsApi getUserCompanionsApi() {
    return UserCompanionsApi(dio, serializers);
  }

  /// Get UserPreferencesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UserPreferencesApi getUserPreferencesApi() {
    return UserPreferencesApi(dio, serializers);
  }

  /// Get UserProfilesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UserProfilesApi getUserProfilesApi() {
    return UserProfilesApi(dio, serializers);
  }

  /// Get UsersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UsersApi getUsersApi() {
    return UsersApi(dio, serializers);
  }

  /// Get WeatherApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WeatherApi getWeatherApi() {
    return WeatherApi(dio, serializers);
  }
}
