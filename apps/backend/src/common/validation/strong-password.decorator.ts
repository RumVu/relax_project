import { Matches, MaxLength, MinLength } from 'class-validator';

const STRONG_PASSWORD_REGEX =
  /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).+$/;

export function StrongPassword() {
  return function (target: object, propertyKey: string) {
    MinLength(10, {
      message: 'Password must be at least 10 characters long',
    })(target, propertyKey);
    MaxLength(72, {
      message: 'Password must be at most 72 characters long',
    })(target, propertyKey);
    Matches(STRONG_PASSWORD_REGEX, {
      message:
        'Password must include uppercase, lowercase, number, and special character',
    })(target, propertyKey);
  };
}
