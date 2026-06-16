'use client';

import { useState } from 'react';
import { Laptop } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle, DataTable } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';
import { describeDevice, describeBrowser } from '@/lib/user-agent';
import { SessionsPagination } from '../components/pagination';

interface SessionsSectionProps {
  t: any;
  locale: 'vi' | 'en';
  copy: any;
  settings: any;
  triggerRefresh: () => void;
  pushToast: (toast: any) => void;
}

export function SessionsSection({
  t,
  locale,
  copy,
  settings,
  triggerRefresh,
  pushToast,
}: SessionsSectionProps) {
  const [sessionsPage, setSessionsPage] = useState(0);
  const [sessionsPageSize, setSessionsPageSize] = useState(10);
  const [revokingSessionId, setRevokingSessionId] = useState<string | null>(null);

  return (
    <Card>
      <SectionTitle
        title={copy.sessionsTitle}
        copy={copy.sessionsCopy}
        action={<Laptop className="h-5 w-5 text-violet" />}
      />
      <div className="mt-5">
        <DataTable
          columns={[
            t('sessions.field.device'),
            t('sessions.field.browser'),
            'IP',
            t('sessions.field.loginTime'),
            t('sessions.field.expires'),
            t('catalog.col.status'),
            t('sessions.col.action'),
          ]}
          rows={settings.sessions
            .slice(
              sessionsPage * sessionsPageSize,
              (sessionsPage + 1) * sessionsPageSize,
            )
            .map((session: any) => [
              <div
                className="max-w-[220px]"
                key={`${session.id}-device`}
                title={session.device}
              >
                <p className="font-bold">{describeDevice(session.device, locale)}</p>
              </div>,
              <span
                className="text-sm font-semibold"
                key={`${session.id}-browser`}
              >
                {describeBrowser(session.device)}
              </span>,
              <code
                className="rounded bg-[var(--field-bg)] px-2 py-1 text-xs"
                key={`${session.id}-ip`}
              >
                {session.ipAddress || '—'}
              </code>,
              session.createdAt,
              session.expiresAt,
              session.current ? copy.currentSession : copy.savedSession,
              session.current ? (
                <span
                  className="text-xs italic text-slate"
                  key={`${session.id}-action`}
                >
                  —
                </span>
              ) : (
                <Button
                  className="h-8 px-3 text-xs"
                  disabled={revokingSessionId === session.id}
                  key={`${session.id}-action`}
                  onClick={async () => {
                    setRevokingSessionId(session.id);
                    try {
                      await apiFetch(`/sessions/${session.id}`, {
                        method: 'DELETE',
                      });
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title: t('sessions.toast.revokedTitle'),
                        message: t('sessions.toast.revokedMessage'),
                      });
                    } catch (err) {
                      const message =
                        err instanceof Error ? err.message : String(err);
                      pushToast({
                        tone: 'error',
                        title: t('sessions.toast.revokeFailedTitle'),
                        message,
                      });
                    } finally {
                      setRevokingSessionId(null);
                    }
                  }}
                  variant="ghost"
                >
                  {revokingSessionId === session.id
                    ? t('sessions.action.revoking')
                    : t('sessions.action.revoke')}
                </Button>
              ),
            ])}
        />
        <SessionsPagination
          page={sessionsPage}
          pageSize={sessionsPageSize}
          setPage={setSessionsPage}
          setPageSize={setSessionsPageSize}
          total={settings.sessions.length}
        />
      </div>
      <p className="mt-4 text-sm text-[var(--app-muted,theme(colors.slate))]">
        {copy.sessionsNote}
      </p>
    </Card>
  );
}
