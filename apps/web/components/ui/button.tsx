import { ButtonHTMLAttributes } from 'react';
import { cn } from '@/lib/utils';

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: 'primary' | 'secondary' | 'ghost';
};

export function Button({ className, variant = 'primary', ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'inline-flex h-10 items-center justify-center gap-2 rounded-lg px-4 text-sm font-semibold transition disabled:cursor-not-allowed disabled:opacity-60',
        variant === 'primary' &&
          'bg-[var(--brand-primary)] text-white hover:bg-[var(--brand-accent)]',
        variant === 'secondary' &&
          'border border-[var(--field-border)] bg-[var(--panel-strong)] text-[var(--app-text)] hover:bg-lilac/40',
        variant === 'ghost' &&
          'bg-transparent text-[var(--app-text)] hover:bg-white/20',
        className,
      )}
      {...props}
    />
  );
}
