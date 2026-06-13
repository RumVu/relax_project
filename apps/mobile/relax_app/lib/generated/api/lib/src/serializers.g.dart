// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(AdminLogActorDto.serializer)
      ..add(AdminLogPageDto.serializer)
      ..add(AdminLogResponseDto.serializer)
      ..add(AmbientSoundPageDto.serializer)
      ..add(AmbientSoundResponseDto.serializer)
      ..add(AppThemePageDto.serializer)
      ..add(AppThemeResponseDto.serializer)
      ..add(AuthActionResultDto.serializer)
      ..add(AuthResponseDto.serializer)
      ..add(BillingMeResponseDto.serializer)
      ..add(BillingPlanLimitDto.serializer)
      ..add(BillingPlanResponseDto.serializer)
      ..add(BreathingExercisePageDto.serializer)
      ..add(BreathingExerciseResponseDto.serializer)
      ..add(ChangePasswordDto.serializer)
      ..add(CheckContentDto.serializer)
      ..add(CheckoutResolvedPlanDto.serializer)
      ..add(CheckoutSessionResponseDto.serializer)
      ..add(CheckoutSessionStatusDto.serializer)
      ..add(CompanionAssetPageDto.serializer)
      ..add(CompanionAssetResponseDto.serializer)
      ..add(CompanionChatDto.serializer)
      ..add(CompanionMessagePageDto.serializer)
      ..add(CompanionMessageResponseDto.serializer)
      ..add(ConfirmPaymentDto.serializer)
      ..add(ConfirmPaymentPlanDto.serializer)
      ..add(ConfirmPaymentResponseDto.serializer)
      ..add(CozyQuotePageDto.serializer)
      ..add(CozyQuoteResponseDto.serializer)
      ..add(CreateAmbientSoundDto.serializer)
      ..add(CreateAppThemeDto.serializer)
      ..add(CreateBreathingExerciseDto.serializer)
      ..add(CreateCheckoutSessionDto.serializer)
      ..add(CreateCheckoutSessionDtoProviderEnum.serializer)
      ..add(CreateCompanionAssetDto.serializer)
      ..add(CreateCompanionInteractionDto.serializer)
      ..add(CreateCompanionMessageDto.serializer)
      ..add(CreateCozyQuoteDto.serializer)
      ..add(CreateExperimentDto.serializer)
      ..add(CreateJournalDto.serializer)
      ..add(CreateMeditationSessionDto.serializer)
      ..add(CreateMoodCheckinDto.serializer)
      ..add(CreateNotificationDto.serializer)
      ..add(CreateOnboardingSlideDto.serializer)
      ..add(CreateReminderDto.serializer)
      ..add(CreateSignedUploadUrlDto.serializer)
      ..add(CreateSleepSessionDto.serializer)
      ..add(CreateTierDto.serializer)
      ..add(CreateTierDtoBillingCycleEnum.serializer)
      ..add(CreateUserDto.serializer)
      ..add(DeleteAccountDto.serializer)
      ..add(DeleteAccountDtoModeEnum.serializer)
      ..add(DemoLoginDto.serializer)
      ..add(ErrorResponse.serializer)
      ..add(ErrorResponseCodeEnum.serializer)
      ..add(FeedbackInsightDto.serializer)
      ..add(FinishRelaxSessionDto.serializer)
      ..add(GoogleLoginDto.serializer)
      ..add(JournalPageDto.serializer)
      ..add(JournalResponseDto.serializer)
      ..add(LogExperimentEventDto.serializer)
      ..add(LogExperimentEventDtoEventTypeEnum.serializer)
      ..add(LoginDto.serializer)
      ..add(MoodCheckinPageDto.serializer)
      ..add(MoodCheckinResponseDto.serializer)
      ..add(NotificationPageDto.serializer)
      ..add(NotificationResponseDto.serializer)
      ..add(OnboardingSlidePageDto.serializer)
      ..add(OnboardingSlideResponseDto.serializer)
      ..add(PaymentResponseDto.serializer)
      ..add(ProviderStatusResponseDto.serializer)
      ..add(PushDeviceResponseDto.serializer)
      ..add(RateContentDto.serializer)
      ..add(RecalculateWeeklyMoodStatsDto.serializer)
      ..add(RefreshTokenDto.serializer)
      ..add(RegisterDto.serializer)
      ..add(RegisterPushDeviceDto.serializer)
      ..add(RegisterStorageFileDto.serializer)
      ..add(RelaxSessionPageDto.serializer)
      ..add(RelaxSessionResponseDto.serializer)
      ..add(ReminderPageDto.serializer)
      ..add(ReminderResponseDto.serializer)
      ..add(RemoveStorageObjectDto.serializer)
      ..add(RequestPasswordResetDto.serializer)
      ..add(ResetPasswordDto.serializer)
      ..add(RunWeeklyMoodStatsJobDto.serializer)
      ..add(SessionResponseDto.serializer)
      ..add(SetUserPlanDto.serializer)
      ..add(StartRelaxSessionDto.serializer)
      ..add(StorageFileResponseDto.serializer)
      ..add(SubscriptionResponseDto.serializer)
      ..add(SwitchCompanionPersonalizationDto.serializer)
      ..add(TierNameDto.serializer)
      ..add(UnreadCountResponseDto.serializer)
      ..add(UpdateAmbientSoundDto.serializer)
      ..add(UpdateAppThemeDto.serializer)
      ..add(UpdateBreathingExerciseDto.serializer)
      ..add(UpdateCompanionAssetDto.serializer)
      ..add(UpdateCompanionMessageDto.serializer)
      ..add(UpdateCozyQuoteDto.serializer)
      ..add(UpdateExperimentDto.serializer)
      ..add(UpdateJournalDto.serializer)
      ..add(UpdateMoodCheckinDto.serializer)
      ..add(UpdateOnboardingSlideDto.serializer)
      ..add(UpdateReminderDto.serializer)
      ..add(UpdateTierDto.serializer)
      ..add(UpdateTierDtoBillingCycleEnum.serializer)
      ..add(UpdateUserDto.serializer)
      ..add(UpdateWeatherLocationDto.serializer)
      ..add(UpsertFeatureFlagDto.serializer)
      ..add(UpsertUserCompanionDto.serializer)
      ..add(UpsertUserPreferenceDto.serializer)
      ..add(UpsertUserProfileDto.serializer)
      ..add(UserCompanionResponseDto.serializer)
      ..add(UserPageDto.serializer)
      ..add(UserPreferenceResponseDto.serializer)
      ..add(UserProfileResponseDto.serializer)
      ..add(UserResponseDto.serializer)
      ..add(UserSubscriptionSummaryDto.serializer)
      ..add(VerifyEmailDto.serializer)
      ..add(WeatherCurrentDataDto.serializer)
      ..add(WeatherCurrentResponseDto.serializer)
      ..add(WeatherForecastDayDto.serializer)
      ..add(WeatherForecastResponseDto.serializer)
      ..add(WeatherGreetingDto.serializer)
      ..add(WeatherLocationDto.serializer)
      ..add(WeeklyMoodStatResponseDto.serializer)
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(AdminLogResponseDto)]),
          () => ListBuilder<AdminLogResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(AmbientSoundResponseDto)]),
          () => ListBuilder<AmbientSoundResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(AppThemeResponseDto)]),
          () => ListBuilder<AppThemeResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(BreathingExerciseResponseDto)]),
          () => ListBuilder<BreathingExerciseResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CompanionAssetResponseDto)]),
          () => ListBuilder<CompanionAssetResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CompanionMessageResponseDto)]),
          () => ListBuilder<CompanionMessageResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CozyQuoteResponseDto)]),
          () => ListBuilder<CozyQuoteResponseDto>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(JournalResponseDto)]),
          () => ListBuilder<JournalResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(MoodCheckinResponseDto)]),
          () => ListBuilder<MoodCheckinResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(NotificationResponseDto)]),
          () => ListBuilder<NotificationResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(OnboardingSlideResponseDto)]),
          () => ListBuilder<OnboardingSlideResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(RelaxSessionResponseDto)]),
          () => ListBuilder<RelaxSessionResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(ReminderResponseDto)]),
          () => ListBuilder<ReminderResponseDto>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(BillingPlanLimitDto)]),
          () => ListBuilder<BillingPlanLimitDto>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(UserResponseDto)]),
          () => ListBuilder<UserResponseDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(UserSubscriptionSummaryDto)]),
          () => ListBuilder<UserSubscriptionSummaryDto>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(WeatherForecastDayDto)]),
          () => ListBuilder<WeatherForecastDayDto>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
