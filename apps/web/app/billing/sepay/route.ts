import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  try {
    const authHeader = request.headers.get('authorization') || '';
    const body = await request.json();

    // Lấy URL Backend từ biến môi trường của Next.js
    const backendUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:6823/v1';
    
    console.log(`[Next.js Gateway] forwarding SePay IPN webhook to: ${backendUrl}/billing/webhooks/sepay`);

    // Chuyển tiếp request sang NestJS backend
    const response = await fetch(`${backendUrl}/billing/webhooks/sepay`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
      },
      body: JSON.stringify(body),
    });

    const data = await response.json();

    return NextResponse.json(data, { status: response.status });
  } catch (error: any) {
    console.error('[Next.js Gateway] Error forwarding SePay IPN:', error);
    return NextResponse.json(
      { 
        success: false, 
        message: 'Lỗi chuyển tiếp IPN từ Next.js Gateway sang Backend', 
        error: error.message 
      },
      { status: 500 }
    );
  }
}
