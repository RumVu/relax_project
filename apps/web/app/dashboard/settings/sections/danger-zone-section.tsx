'use client';

import { useState } from 'react';
import { AlertTriangle, Trash2 } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { DeleteAccountModal } from '../components/delete-account-modal';

interface DangerZoneSectionProps {
  t: any;
  locale: 'vi' | 'en';
  authProvider: string;
}

export function DangerZoneSection({
  t,
  locale,
  authProvider,
}: DangerZoneSectionProps) {
  const [deleteAccountModalOpen, setDeleteAccountModalOpen] = useState(false);

  return (
    <>
      <Card className="border-coral/20 bg-coral/5">
        <SectionTitle
          title={t('settings.danger.heading')}
          copy={t('settings.danger.warning')}
          action={<AlertTriangle className="h-5 w-5 text-coral animate-pulse" />}
        />
        <div className="mt-5">
          <p className="text-sm font-semibold text-[var(--app-muted)]">
            {locale === 'en'
              ? 'Once you delete or anonymize your account, all your data (mood checkins, journals, sessions) will be either anonymized or permanently deleted depending on the mode.'
              : 'Sau khi anh xóa hoặc ẩn danh hóa tài khoản, toàn bộ dữ liệu (nhật ký, cảm xúc, lịch sử đăng nhập) sẽ được ẩn danh hoặc xóa vĩnh viễn tùy thuộc vào chế độ.'}
          </p>
          <div className="mt-4">
            <Button
              onClick={() => {
                setDeleteAccountModalOpen(true);
              }}
              variant="secondary"
              className="border-coral text-coral hover:bg-coral/10 hover:text-coral transition-colors"
            >
              <Trash2 className="h-4 w-4" />
              {t('settings.security.deleteAccount')}
            </Button>
          </div>
        </div>
      </Card>
      {deleteAccountModalOpen ? (
        <DeleteAccountModal
          isOpen={deleteAccountModalOpen}
          onClose={() => setDeleteAccountModalOpen(false)}
          authProvider={authProvider}
        />
      ) : null}
    </>
  );
}
