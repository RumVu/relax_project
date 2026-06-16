'use client';

import type { LucideIcon } from 'lucide-react';

export function Field({
  label,
  value,
  type = 'text',
  onChange,
  select = false,
  options = [],
}: {
  label: string;
  value: string;
  type?: string;
  onChange?: (value: string) => void;
  select?: boolean;
  options?: string[];
}) {
  return (
    <label>
      <span className="text-sm font-semibold text-slate">{label}</span>
      {select ? (
        <select
          className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange?.(event.target.value)}
          value={value}
        >
          {options.map((option) => (
            <option key={option} value={option}>
              {option}
            </option>
          ))}
        </select>
      ) : (
        <input
          className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange?.(event.target.value)}
          readOnly={!onChange}
          type={type}
          value={value}
        />
      )}
    </label>
  );
}

export function ToggleCard({
  checked,
  icon: Icon,
  label,
  onClick,
}: {
  checked: boolean;
  icon: LucideIcon;
  label: string;
  onClick: () => void;
}) {
  return (
    <button
      className={`rounded-lg border p-4 text-left transition ${
        checked
          ? 'border-violet bg-violet text-white'
          : 'border-lilac/70 bg-white/75 text-ink'
      }`}
      onClick={onClick}
      type="button"
    >
      <Icon className="h-5 w-5" />
      <p className="mt-4 font-bold">{label}</p>
      <p
        className={`mt-1 text-xs font-semibold ${
          checked ? 'text-white/70' : 'text-slate'
        }`}
      >
        {checked ? 'Enabled' : 'Disabled'}
      </p>
    </button>
  );
}

export function DerivedCard({
  icon: Icon,
  label,
  note,
  value,
}: {
  icon: LucideIcon;
  label: string;
  note: string;
  value: string;
}) {
  return (
    <div className="rounded-lg border border-lilac/70 bg-white/75 p-4">
      <Icon className="h-5 w-5 text-violet" />
      <p className="mt-4 text-sm font-semibold text-slate">{label}</p>
      <p className="mt-1 text-xl font-extrabold text-ink">{value}</p>
      <p className="mt-1 text-xs font-medium text-plum">{note}</p>
    </div>
  );
}

export function StatusMiniCard({
  title,
  value,
  note,
}: {
  title: string;
  value: string;
  note: string;
}) {
  return (
    <div className="rounded-lg border border-lilac/70 bg-white/75 p-4">
      <p className="text-xs font-semibold uppercase tracking-[0.14em] text-slate">
        {title}
      </p>
      <p className="mt-2 text-sm font-extrabold text-ink">{value}</p>
      <p className="mt-1 text-xs font-medium text-plum">{note}</p>
    </div>
  );
}

