/**
 * Validation guards for weather inputs.
 */
import { HttpStatus } from '@nestjs/common';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-code';

/**
 * Latitude/longitude must arrive together or both missing — passing
 * only one is a client bug we want to surface loudly.
 */
export function assertCoordinatePair(
  latitude?: number | null,
  longitude?: number | null,
): void {
  if (
    (latitude == null && longitude != null) ||
    (latitude != null && longitude == null)
  ) {
    throw new AppException(
      ErrorCode.VALIDATION_FAILED,
      'Latitude and longitude must be provided together',
      HttpStatus.BAD_REQUEST,
    );
  }
}
