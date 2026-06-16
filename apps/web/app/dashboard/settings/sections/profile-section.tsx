'use client';

import { useState } from 'react';
import { Save, WandSparkles } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { AvatarUploader } from '@/components/dashboard/avatar-uploader';
import { BirthdayInput } from '@/components/ui/birthday-input';
import { apiFetch } from '@/lib/api';
import { computeZodiac, zodiacLabel, chineseZodiacLabel } from '@/lib/zodiac';
import { normalizeBirthdayValue } from '../settings-utils';
import { Field, DerivedCard } from '../components/ui-cards';

interface ProfileSectionProps {
  t: any;
  locale: 'vi' | 'en';
  avatar: string | null;
  displayName: string;
  birthday: string;
  email: string;
  zodiacSign: string;
  chineseZodiac: string;
  accountProfile: any;
  setAccountProfile: (val: any) => void;
  triggerRefresh: () => void;
  setRefreshKey: (updater: (prev: number) => number) => void;
  pushToast: (toast: any) => void;
}

export function ProfileSection({
  t,
  locale,
  avatar: initialAvatar,
  displayName: serverDisplayName,
  birthday: serverBirthday,
  email,
  zodiacSign,
  chineseZodiac,
  accountProfile,
  setAccountProfile,
  triggerRefresh,
  setRefreshKey,
  pushToast,
}: ProfileSectionProps) {
  const [profileDraft, setProfileDraft] = useState<{
    displayName: string;
    birthday: string;
  } | null>(null);
  const [avatarOverride, setAvatarOverride] = useState<string | null | undefined>(
    undefined,
  );
  const [profileState, setProfileState] = useState<'idle' | 'saving'>('idle');

  const displayName = profileDraft?.displayName ?? serverDisplayName;
  const birthday =
    profileDraft?.birthday ?? normalizeBirthdayValue(serverBirthday);
  const avatar =
    avatarOverride !== undefined
      ? avatarOverride
      : accountProfile?.avatar ?? initialAvatar;

  return (
    <Card>
      <SectionTitle
        title={t('settings.section.profile.title')}
        copy={t('settings.section.profile.copy')}
      />
      <div className="mt-5 rounded-lg border border-lilac/60 bg-white/60 p-4">
        <AvatarUploader
          currentAvatar={avatar}
          displayName={displayName}
          key={avatar ?? 'empty-avatar'}
          onUpdated={(publicUrl) => {
            const nextAvatar = publicUrl || null;
            setAvatarOverride(nextAvatar);
            setAccountProfile({
              avatar: nextAvatar,
              displayName,
              email: email,
            });
            triggerRefresh();
          }}
        />
      </div>
      <div className="mt-5 grid gap-4">
        <Field
          label={t('settings.field.displayName')}
          value={displayName}
          onChange={(value) =>
            setProfileDraft((current) => ({
              displayName: value,
              birthday:
                current?.birthday ??
                normalizeBirthdayValue(serverBirthday),
            }))
          }
        />
        <BirthdayInput
          label={t('settings.field.birthday')}
          value={birthday}
          onChange={(value) =>
            setProfileDraft((current) => ({
              displayName:
                current?.displayName ?? serverDisplayName,
              birthday: value,
            }))
          }
        />
        {(() => {
          const previewed = computeZodiac(birthday);
          const liveZodiac =
            zodiacLabel(previewed.zodiacSign, locale) !== '—'
              ? zodiacLabel(previewed.zodiacSign, locale)
              : zodiacSign;
          const liveChinese =
            chineseZodiacLabel(previewed.chineseZodiac, locale) !== '—'
              ? chineseZodiacLabel(previewed.chineseZodiac, locale)
              : chineseZodiac;
          return (
            <div className="grid gap-3 sm:grid-cols-2">
              <DerivedCard
                icon={WandSparkles}
                label={t('settings.field.zodiacWestern')}
                note={t('settings.zodiac.auto')}
                value={liveZodiac}
              />
              <DerivedCard
                icon={WandSparkles}
                label={t('settings.field.zodiacChinese')}
                note={t('settings.zodiac.chineseAuto')}
                value={liveChinese}
              />
            </div>
          );
        })()}
      </div>
      <Button
        className="mt-5"
        disabled={profileState === 'saving'}
        onClick={async () => {
          setProfileState('saving');
          try {
            await apiFetch('/user-profiles/me/profile', {
              method: 'PATCH',
              body: JSON.stringify({
                displayName,
                birthday: birthday
                  ? new Date(`${birthday}T00:00:00.000Z`).toISOString()
                  : null,
              }),
            });
            setAccountProfile({
              displayName,
              name: displayName,
              email: email,
            });
            setRefreshKey((current) => current + 1);
            triggerRefresh();
            setProfileDraft(null);
            pushToast({
              tone: 'success',
              title: t('settings.toast.profileSaved'),
              message: t('settings.toast.profileSavedMessage'),
            });
          } catch {
            pushToast({
              tone: 'error',
              title: t('settings.toast.profileFailed'),
              message: t('settings.toast.serverHint'),
            });
          } finally {
            setProfileState('idle');
          }
        }}
      >
        <Save className="h-4 w-4" />
        {profileState === 'saving' ? t('settings.btn.savingProfile') : t('settings.btn.saveProfile')}
      </Button>
    </Card>
  );
}
