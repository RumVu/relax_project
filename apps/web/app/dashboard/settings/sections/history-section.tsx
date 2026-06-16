'use client';

import { useState } from 'react';
import { CreditCard } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { SectionTitle, DataTable } from '@/components/dashboard/dashboard-ui';
import { PaymentsPagination } from '../components/pagination';
import { formatPlanPrice } from '../settings-utils';

interface HistorySectionProps {
  locale: 'vi' | 'en';
  copy: any;
  settings: any;
}

export function HistorySection({
  locale,
  copy,
  settings,
}: HistorySectionProps) {
  const [paymentsPage, setPaymentsPage] = useState(0);
  const [paymentsPageSize, setPaymentsPageSize] = useState<10 | 20 | 50>(10);

  return (
    <Card>
      <SectionTitle
        title={copy.historyTitle}
        copy={copy.historyCopy}
        action={<CreditCard className="h-5 w-5 text-violet" />}
      />
      <div className="mt-5">
        {settings.payments && settings.payments.length > 0 ? (
          <>
            <DataTable
              columns={[
                copy.colPlan,
                copy.colAmount,
                copy.colOrderCode,
                copy.colTxCode,
                copy.colMethod,
                copy.colDate,
                copy.colStatus,
              ]}
              rows={settings.payments
                .slice(
                  paymentsPage * paymentsPageSize,
                  (paymentsPage + 1) * paymentsPageSize,
                )
                .map((payment: any) => {
                  let planTitle = payment.description || 'N/A';
                  if (planTitle.includes('Upgrade intent from dashboard to')) {
                    planTitle = planTitle.replace('Upgrade intent from dashboard to', '').trim();
                  } else if (planTitle.includes('Upgrade to')) {
                    planTitle = planTitle.replace('Upgrade to', '').trim();
                  }

                  let statusBadge = (
                    <span className="inline-flex rounded-full bg-slate-100 px-2 py-0.5 text-xs font-bold text-slate-600">
                      {payment.status}
                    </span>
                  );
                  if (payment.status === 'COMPLETED') {
                    statusBadge = (
                      <span className="inline-flex rounded-full bg-emerald-500/15 px-2 py-0.5 text-xs font-bold text-emerald-500">
                        {copy.statusSuccess}
                      </span>
                    );
                  } else if (payment.status === 'PENDING') {
                    statusBadge = (
                      <span className="inline-flex rounded-full bg-amber-500/15 px-2 py-0.5 text-xs font-bold text-amber-500 animate-pulse">
                        {copy.statusPending}
                      </span>
                    );
                  } else if (payment.status === 'FAILED') {
                    statusBadge = (
                      <span className="inline-flex rounded-full bg-red-500/15 px-2 py-0.5 text-xs font-bold text-red-500">
                        {copy.statusFailed}
                      </span>
                    );
                  }

                  return [
                    <span className="font-bold text-ink" key={`${payment.id}-plan`}>
                      {planTitle}
                    </span>,
                    <span className="font-semibold text-plum" key={`${payment.id}-amount`}>
                      {formatPlanPrice(payment.amount, payment.currency, locale)}
                    </span>,
                    <code className="text-xs text-slate-500" key={`${payment.id}-id`}>
                      {payment.id}
                    </code>,
                    <code className="text-xs text-violet font-bold" key={`${payment.id}-tx`}>
                      {payment.externalPaymentId || '—'}
                    </code>,
                    <span className="inline-flex rounded bg-violet/10 px-1.5 py-0.5 text-xs font-bold text-violet" key={`${payment.id}-provider`}>
                      {payment.provider}
                    </span>,
                    <span className="text-xs text-slate-500" key={`${payment.id}-date`}>
                      {payment.createdAt}
                    </span>,
                    <div key={`${payment.id}-status`}>{statusBadge}</div>,
                  ];
                })}
            />
            <PaymentsPagination
              page={paymentsPage}
              pageSize={paymentsPageSize}
              setPage={setPaymentsPage}
              setPageSize={(size) => {
                setPaymentsPageSize(size);
                setPaymentsPage(0);
              }}
              total={settings.payments.length}
            />
          </>
        ) : (
          <div className="rounded-lg border border-dashed border-lilac bg-white/70 p-5 text-sm font-medium text-slate">
            {locale === 'en' ? 'No transactions found.' : 'Chưa có giao dịch nào được thực hiện.'}
          </div>
        )}
      </div>
    </Card>
  );
}
