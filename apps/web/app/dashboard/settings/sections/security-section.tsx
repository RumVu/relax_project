'use client';

import { useState } from 'react';
import { KeyRound } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';
import { isStrongPassword } from '@/lib/password';
import { Field } from '../components/ui-cards';

interface SecuritySectionProps {
  t: any;
  pushToast: (toast: any) => void;
}

export function SecuritySection({ t, pushToast }: SecuritySectionProps) {
  const [passwordDraft, setPasswordDraft] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
  });
  const [passwordState, setPasswordState] = useState<'idle' | 'saving'>('idle');

  return (
    <Card>
      <SectionTitle
        title={t('settings.section.security.title')}
        copy={t('settings.section.security.copy')}
        action={<KeyRound className="h-5 w-5 text-violet" />}
      />
      <form
        className="mt-5 grid gap-4 lg:grid-cols-3"
        onSubmit={async (event) => {
          event.preventDefault();
          if (passwordDraft.newPassword !== passwordDraft.confirmPassword) {
            pushToast({
              tone: 'error',
              title: t('settings.toast.passwordMismatch'),
            });
            return;
          }
          if (!isStrongPassword(passwordDraft.newPassword)) {
            pushToast({
              tone: 'error',
              title: t('settings.toast.passwordTooShort'),
            });
            return;
          }

          setPasswordState('saving');
          try {
            await apiFetch('/auth/me/password', {
              method: 'PATCH',
              body: JSON.stringify({
                currentPassword: passwordDraft.currentPassword,
                newPassword: passwordDraft.newPassword,
              }),
            });
            setPasswordDraft({
              currentPassword: '',
              newPassword: '',
              confirmPassword: '',
            });
            pushToast({
              tone: 'success',
              title: t('settings.toast.passwordChanged'),
            });
          } catch {
            pushToast({
              tone: 'error',
              title: t('settings.password.changeFailed'),
              message: t('settings.toast.serverHint'),
            });
          } finally {
            setPasswordState('idle');
          }
        }}
      >
        <Field
          label={t('settings.field.currentPassword')}
          onChange={(value) =>
            setPasswordDraft((current) => ({
              ...current,
              currentPassword: value,
            }))
          }
          type="password"
          value={passwordDraft.currentPassword}
        />
        <Field
          label={t('settings.field.newPassword')}
          onChange={(value) =>
            setPasswordDraft((current) => ({
              ...current,
              newPassword: value,
            }))
          }
          type="password"
          value={passwordDraft.newPassword}
        />
        <Field
          label={t('settings.field.confirmPassword')}
          onChange={(value) =>
            setPasswordDraft((current) => ({
              ...current,
              confirmPassword: value,
            }))
          }
          type="password"
          value={passwordDraft.confirmPassword}
        />
        <p className="text-xs font-semibold text-slate lg:col-span-3">
          {t('settings.toast.passwordTooShort')}
        </p>
        <div className="lg:col-span-3">
          <Button
            disabled={
              passwordState === 'saving' ||
              !passwordDraft.currentPassword ||
              !passwordDraft.newPassword ||
              !passwordDraft.confirmPassword
            }
            type="submit"
          >
            <KeyRound className="h-4 w-4" />
            {passwordState === 'saving'
              ? t('settings.btn.changingPassword')
              : t('settings.btn.changePassword')}
          </Button>
        </div>
      </form>
    </Card>
  );
}
