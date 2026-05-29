/**
 * Helpers for asking the browser for permission to use sensitive
 * capabilities (geolocation, notifications, microphone, …) AND for
 * detecting the common silent-failure modes (insecure context, denied
 * permission, browser without support) before we call the underlying
 * API.
 *
 * Why: a lot of these APIs fail silently when invoked from an
 * insecure context (eg. http://192.168.x.x:3233 over LAN — geolocation
 * + Notification permission prompts simply don't show in Chrome /
 * Safari when the origin is not localhost and not HTTPS). The user
 * thinks they clicked "Allow" but nothing happened.
 */

export type CapabilityName =
  | 'geolocation'
  | 'notification'
  | 'audio'
  | 'storage';

export type CapabilityStatus =
  | 'granted'
  | 'denied'
  | 'prompt'
  | 'unsupported'
  | 'insecure-context';

export type CapabilityReport = {
  name: CapabilityName;
  status: CapabilityStatus;
  description: string;
  hint?: string;
};

/**
 * True when the page was loaded over a context the browser considers
 * "secure" — that's https://*, http://localhost, or file://. Geolocation
 * + Notifications + many other modern APIs require this.
 */
export function isSecureContext(): boolean {
  if (typeof window === 'undefined') return false;
  if (window.isSecureContext) return true;
  // Fallback for older browsers that don't expose isSecureContext.
  const host = window.location.hostname;
  return (
    window.location.protocol === 'https:' ||
    host === 'localhost' ||
    host === '127.0.0.1' ||
    host === '[::1]'
  );
}

/**
 * Inspect the current state of every capability we care about. Pure
 * read — does not trigger permission prompts.
 */
export async function auditCapabilities(): Promise<CapabilityReport[]> {
  const secure = isSecureContext();
  const reports: CapabilityReport[] = [];

  // Geolocation
  if (typeof navigator === 'undefined' || !('geolocation' in navigator)) {
    reports.push({
      name: 'geolocation',
      status: 'unsupported',
      description: 'Định vị',
    });
  } else if (!secure) {
    reports.push({
      name: 'geolocation',
      status: 'insecure-context',
      description: 'Định vị',
      hint: 'Browser khoá định vị trên http://<LAN-IP>. Mở app qua http://localhost:3233 hoặc setup HTTPS để dùng.',
    });
  } else {
    let status: CapabilityStatus = 'prompt';
    try {
      const result = await navigator.permissions?.query({
        name: 'geolocation' as PermissionName,
      });
      if (result) status = result.state as CapabilityStatus;
    } catch {
      /* permissions API not available — leave as 'prompt' */
    }
    reports.push({ name: 'geolocation', status, description: 'Định vị' });
  }

  // Notifications
  if (typeof window === 'undefined' || !('Notification' in window)) {
    reports.push({
      name: 'notification',
      status: 'unsupported',
      description: 'Thông báo hệ điều hành',
    });
  } else if (!secure) {
    reports.push({
      name: 'notification',
      status: 'insecure-context',
      description: 'Thông báo hệ điều hành',
      hint: 'Notification API yêu cầu HTTPS hoặc localhost.',
    });
  } else {
    const perm = Notification.permission;
    reports.push({
      name: 'notification',
      status: perm === 'default' ? 'prompt' : (perm as CapabilityStatus),
      description: 'Thông báo hệ điều hành',
    });
  }

  // WebAudio (notify chime)
  if (
    typeof window === 'undefined' ||
    !(window.AudioContext || (window as { webkitAudioContext?: unknown }).webkitAudioContext)
  ) {
    reports.push({
      name: 'audio',
      status: 'unsupported',
      description: 'Âm thanh in-app',
    });
  } else {
    reports.push({
      name: 'audio',
      status: 'granted',
      description: 'Âm thanh in-app',
      hint: 'Cần a tương tác (click) ít nhất 1 lần trước khi browser cho phép phát.',
    });
  }

  // localStorage (auth tokens, draft state)
  try {
    const key = '__perm_probe__';
    window.localStorage.setItem(key, '1');
    window.localStorage.removeItem(key);
    reports.push({
      name: 'storage',
      status: 'granted',
      description: 'localStorage (lưu phiên đăng nhập)',
    });
  } catch {
    reports.push({
      name: 'storage',
      status: 'denied',
      description: 'localStorage (lưu phiên đăng nhập)',
      hint: 'Browser đang chặn cookie/storage — kiểm tra incognito hoặc tracking-protection.',
    });
  }

  return reports;
}

/**
 * Ask the browser for geolocation, with proper error surfacing.
 * Returns the position or throws a friendly error message.
 */
export function requestGeolocation(options?: PositionOptions): Promise<GeolocationPosition> {
  return new Promise((resolve, reject) => {
    if (typeof navigator === 'undefined' || !navigator.geolocation) {
      reject(new Error('Trình duyệt không hỗ trợ định vị.'));
      return;
    }
    if (!isSecureContext()) {
      reject(
        new Error(
          'Browser KHÔNG cho gọi định vị từ origin không an toàn (' +
            window.location.origin +
            '). Mở app qua http://localhost:3233 hoặc HTTPS để dùng được.',
        ),
      );
      return;
    }
    navigator.geolocation.getCurrentPosition(
      resolve,
      (error) => {
        const map: Record<number, string> = {
          1: 'A đã từ chối quyền định vị. Vào setting browser bật lại.',
          2: 'Không lấy được vị trí (mất GPS / wifi).',
          3: 'Hết thời gian chờ định vị.',
        };
        reject(new Error(map[error.code] ?? error.message));
      },
      { enableHighAccuracy: true, timeout: 10_000, ...options },
    );
  });
}

/**
 * Ask the browser for OS-level notification permission. Returns the
 * resulting permission state. Falls back gracefully when the origin
 * is insecure (returns 'denied' with a hint instead of silently
 * failing).
 */
export async function requestNotificationPermission(): Promise<NotificationPermission | 'unsupported'> {
  if (typeof window === 'undefined' || !('Notification' in window)) {
    return 'unsupported';
  }
  if (!isSecureContext()) {
    // Most browsers silently no-op this on http://. Return 'denied' so
    // callers can show a hint instead of pretending it worked.
    return 'denied';
  }
  if (Notification.permission === 'default') {
    try {
      return await Notification.requestPermission();
    } catch {
      return 'denied';
    }
  }
  return Notification.permission;
}
