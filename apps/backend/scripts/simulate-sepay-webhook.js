/**
 * Kịch bản giả lập toàn bộ quy trình thanh toán SePay PG
 * Chạy lệnh: node scripts/simulate-sepay-webhook.js
 */

const BASE_URL = 'http://localhost:6823/v1';
const WEBHOOK_API_KEY = 'test-sepay-key'; // Trùng với SEPAY_WEBHOOK_API_KEY trong .env

async function run() {
  console.log('🚀 Bắt đầu giả lập tích hợp SePay...');

  // 1. Tạo một tài khoản test ngẫu nhiên
  const email = `sepay-test-${Date.now()}@example.com`;
  const password = 'Password123!';
  
  console.log(`\n1. Đăng ký tài khoản test: ${email}`);
  let res = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, name: 'SePay Simulator' })
  });

  if (!res.ok) {
    const err = await res.json();
    console.error('✗ Đăng ký thất bại:', err);
    process.exit(1);
  }

  const registerData = await res.json();
  const token = registerData.accessToken;
  console.log('✓ Đăng ký tài khoản thành công!');

  // 2. Kiểm tra gói cước hiện tại (FREE)
  console.log('\n2. Kiểm tra gói cước ban đầu...');
  res = await fetch(`${BASE_URL}/billing/me`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  let billingMe = await res.json();
  console.log(`✓ Gói hiện tại: ${billingMe.subscription.planName} (Status: ${billingMe.subscription.status})`);

  // 3. Tạo checkout intent qua SePay
  console.log('\n3. Tạo yêu cầu nâng cấp gói CHILL_PLUS (Tạo thanh khoản)...');
  res = await fetch(`${BASE_URL}/billing/me/checkout-session`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({ planName: 'CHILL_PLUS', provider: 'SEPAY' })
  });

  if (!res.ok) {
    const err = await res.json();
    console.error('✗ Tạo checkout session thất bại:', err);
    process.exit(1);
  }

  const checkoutData = await res.json();
  const paymentId = checkoutData.payment.id;
  const amount = checkoutData.checkout.amount;
  console.log(`✓ Tạo pending payment thành công! Payment ID: ${paymentId}`);
  console.log('✓ Các trường SePay PG sinh bởi SDK:');
  console.log(JSON.stringify(checkoutData.checkout.checkoutFormfields, null, 2));

  // 4. Giả lập SePay Webhook bắn transaction về hệ thống
  console.log('\n4. Giả lập ngân hàng báo có (SePay Webhook callback)...');
  const webhookPayload = {
    id: Math.floor(Math.random() * 1000000),
    gateway: 'MB',
    transferType: 'in',
    transferAmount: amount,
    transactionContent: `RELAX${paymentId} CHUYEN KHOAN TEST`,
    code: `RELAX${paymentId}`
  };

  res = await fetch(`${BASE_URL}/billing/sepay/webhook`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Apikey ${WEBHOOK_API_KEY}`
    },
    body: JSON.stringify(webhookPayload)
  });

  if (!res.ok) {
    const err = await res.json();
    console.error('✗ Webhook xử lý thất bại:', err);
    process.exit(1);
  }

  const webhookResult = await res.json();
  console.log('✓ Webhook phản hồi:', webhookResult);

  // 5. Kiểm tra lại gói cước của User
  console.log('\n5. Kiểm tra gói cước mới của user...');
  res = await fetch(`${BASE_URL}/billing/me`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  billingMe = await res.json();
  console.log(`✓ Gói cước mới: ${billingMe.subscription.planName} (Status: ${billingMe.subscription.status})`);
  
  if (billingMe.subscription.planName === 'CHILL_PLUS' && billingMe.subscription.status === 'ACTIVE') {
    console.log('\n🎉 THÀNH CÔNG! Tài khoản đã được tự động nâng cấp lên CHILL_PLUS.');
  } else {
    console.log('\n✗ Thất bại: Gói cước chưa được cập nhật.');
  }
}

run().catch(console.error);
