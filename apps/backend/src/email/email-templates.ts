/**
 * Tiny inline HTML+text templates. Kept in one file — they're short and
 * change rarely. Adding a real template engine would be overkill.
 */

const BRAND = 'Relax';

function shell(title: string, body: string): string {
  return `<!doctype html>
<html lang="vi">
  <head><meta charset="utf-8"><title>${title}</title></head>
  <body style="margin:0;padding:0;background:#f5f3ff;font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;color:#1f2937;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f3ff;padding:32px 0;">
      <tr><td align="center">
        <table width="560" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;box-shadow:0 4px 16px rgba(115,87,246,0.08);overflow:hidden;">
          <tr><td style="padding:32px 40px 8px;">
            <div style="font-weight:700;font-size:20px;color:#7357f6;">${BRAND}</div>
          </td></tr>
          <tr><td style="padding:8px 40px 32px;line-height:1.55;font-size:15px;">${body}</td></tr>
          <tr><td style="padding:16px 40px 32px;font-size:12px;color:#94a3b8;border-top:1px solid #eef2ff;">
            Email tự động — vui lòng không trả lời. Nếu bạn không yêu cầu, có thể bỏ qua thư này.
          </td></tr>
        </table>
      </td></tr>
    </table>
  </body>
</html>`;
}

export function verifyEmailTemplate(opts: {
  displayName?: string | null;
  token: string;
  verifyUrl?: string;
  ttlMinutes: number;
}) {
  const name = opts.displayName?.trim() || 'bạn';
  const ctaHtml = opts.verifyUrl
    ? `<p style="margin:24px 0;"><a href="${opts.verifyUrl}" style="display:inline-block;background:#7357f6;color:#ffffff;text-decoration:none;padding:12px 24px;border-radius:10px;font-weight:600;">Xác thực email</a></p>
       <p style="font-size:13px;color:#64748b;">Hoặc nhập mã sau vào ứng dụng:</p>`
    : `<p>Nhập mã xác thực sau vào ứng dụng:</p>`;
  const body = `
    <h2 style="margin:0 0 16px;font-size:20px;">Chào ${name},</h2>
    <p>Cảm ơn ${name} đã đăng ký ${BRAND}. Vui lòng xác thực địa chỉ email để bắt đầu sử dụng đầy đủ tính năng.</p>
    ${ctaHtml}
    <p style="font-family:ui-monospace,Menlo,monospace;background:#eef2ff;padding:12px 16px;border-radius:8px;font-size:14px;word-break:break-all;">${opts.token}</p>
    <p style="color:#64748b;font-size:13px;">Mã có hiệu lực trong ${opts.ttlMinutes} phút.</p>
  `;
  const text = [
    `Chào ${name},`,
    '',
    `Cảm ơn đã đăng ký ${BRAND}. Hãy xác thực email bằng mã:`,
    opts.token,
    opts.verifyUrl ? `Hoặc mở link: ${opts.verifyUrl}` : '',
    '',
    `Mã có hiệu lực trong ${opts.ttlMinutes} phút.`,
  ]
    .filter(Boolean)
    .join('\n');
  return {
    subject: `Xác thực email ${BRAND}`,
    html: shell(`Xác thực email ${BRAND}`, body),
    text,
  };
}

export function otpTemplate(opts: {
  displayName?: string | null;
  otp: string;
  purpose: 'registration' | 'password-reset';
  ttlMinutes: number;
}) {
  const name = opts.displayName?.trim() || 'bạn';
  const isReg = opts.purpose === 'registration';
  const heading = isReg ? 'Xác thực tài khoản' : 'Đặt lại mật khẩu';
  const intro = isReg
    ? `Cảm ơn ${name} đã đăng ký ${BRAND}. Nhập mã OTP bên dưới để xác thực email.`
    : `Bạn (hoặc ai đó) đã yêu cầu đặt lại mật khẩu cho tài khoản ${BRAND}. Nhập mã OTP bên dưới để tiếp tục.`;
  const body = `
    <h2 style="margin:0 0 16px;font-size:20px;">Chào ${name},</h2>
    <p>${intro}</p>
    <p style="text-align:center;margin:28px 0;">
      <span style="display:inline-block;font-family:ui-monospace,Menlo,monospace;background:#eef2ff;padding:16px 32px;border-radius:12px;font-size:32px;font-weight:700;letter-spacing:8px;color:#7357f6;">${opts.otp}</span>
    </p>
    <p style="color:#64748b;font-size:13px;">Mã có hiệu lực trong ${opts.ttlMinutes} phút. Nếu không phải bạn yêu cầu, hãy bỏ qua email này.</p>
  `;
  const text = [
    `Chào ${name},`,
    '',
    intro,
    '',
    `Mã OTP: ${opts.otp}`,
    '',
    `Mã có hiệu lực trong ${opts.ttlMinutes} phút.`,
  ].join('\n');
  const subject = isReg
    ? `${opts.otp} — Mã xác thực ${BRAND}`
    : `${opts.otp} — Đặt lại mật khẩu ${BRAND}`;
  return {
    subject,
    html: shell(`${heading} — ${BRAND}`, body),
    text,
  };
}

export function resetPasswordTemplate(opts: {
  displayName?: string | null;
  token: string;
  resetUrl?: string;
  ttlMinutes: number;
}) {
  const name = opts.displayName?.trim() || 'bạn';
  const ctaHtml = opts.resetUrl
    ? `<p style="margin:24px 0;"><a href="${opts.resetUrl}" style="display:inline-block;background:#7357f6;color:#ffffff;text-decoration:none;padding:12px 24px;border-radius:10px;font-weight:600;">Đặt lại mật khẩu</a></p>
       <p style="font-size:13px;color:#64748b;">Hoặc dùng mã sau:</p>`
    : `<p>Dùng mã sau để đặt lại mật khẩu:</p>`;
  const body = `
    <h2 style="margin:0 0 16px;font-size:20px;">Chào ${name},</h2>
    <p>Bạn (hoặc ai đó) đã yêu cầu đặt lại mật khẩu cho tài khoản ${BRAND}.</p>
    ${ctaHtml}
    <p style="font-family:ui-monospace,Menlo,monospace;background:#eef2ff;padding:12px 16px;border-radius:8px;font-size:14px;word-break:break-all;">${opts.token}</p>
    <p style="color:#64748b;font-size:13px;">Mã có hiệu lực trong ${opts.ttlMinutes} phút. Nếu không phải bạn yêu cầu, có thể bỏ qua thư này.</p>
  `;
  const text = [
    `Chào ${name},`,
    '',
    `Mã đặt lại mật khẩu ${BRAND}:`,
    opts.token,
    opts.resetUrl ? `Hoặc mở link: ${opts.resetUrl}` : '',
    '',
    `Mã có hiệu lực trong ${opts.ttlMinutes} phút. Nếu không phải bạn yêu cầu, hãy bỏ qua.`,
  ]
    .filter(Boolean)
    .join('\n');
  return {
    subject: `Đặt lại mật khẩu ${BRAND}`,
    html: shell(`Đặt lại mật khẩu ${BRAND}`, body),
    text,
  };
}
