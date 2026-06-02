export const PASSWORD_REQUIREMENT =
  'At least 10 characters with uppercase, lowercase, number and symbol.';

export function isStrongPassword(value: string): boolean {
  return (
    value.length >= 10 &&
    value.length <= 72 &&
    /[a-z]/.test(value) &&
    /[A-Z]/.test(value) &&
    /\d/.test(value) &&
    /[^A-Za-z0-9]/.test(value)
  );
}
