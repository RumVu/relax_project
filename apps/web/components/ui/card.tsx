import { cn } from '@/lib/utils';

export function Card({
  className,
  children,
}: {
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <div className={cn('rounded-[28px] border border-white/50 bg-white/75 p-6 shadow-panel backdrop-blur', className)}>
      {children}
    </div>
  );
}
