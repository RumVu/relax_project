import { cn } from '@/lib/utils';

export function Card({
  className,
  children,
}: {
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <div
      className={cn(
        'rounded-lg border border-[var(--panel-border)] bg-[var(--panel-bg)] p-5 text-[var(--app-text)] shadow-panel backdrop-blur',
        className,
      )}
    >
      {children}
    </div>
  );
}
