import { Injectable } from '@nestjs/common';
import { CrisisDetectionResult, detectCrisisContent } from './crisis-keywords';

export interface Hotline {
  name: string;
  phone: string;
  hours: string;
  country: string;
}

export interface SafeResponse {
  message: string;
  hotlines: Hotline[];
  suggestBreathing: boolean;
  suggestEmergencyContact: boolean;
}

@Injectable()
export class CrisisService {
  /**
   * Check free-text content for crisis indicators and return a safety
   * assessment with an optional safe response template.
   */
  checkContent(text: string): {
    safe: boolean;
    severity: CrisisDetectionResult['severity'];
    matchedPatterns: string[];
    safeResponse?: SafeResponse;
  } {
    const result = detectCrisisContent(text);

    if (!result.detected) {
      return { safe: true, severity: 'low', matchedPatterns: [] };
    }

    return {
      safe: false,
      severity: result.severity,
      matchedPatterns: result.matchedPatterns,
      safeResponse: this.getSafeResponse(result.severity),
    };
  }

  /**
   * Build a safe response template appropriate to the severity level.
   */
  getSafeResponse(severity: CrisisDetectionResult['severity']): SafeResponse {
    switch (severity) {
      case 'low':
        return {
          message:
            'Mình hiểu bạn đang có lúc khó khăn. ' +
            'Hãy thử hít thở sâu vài nhịp — đôi khi chỉ cần một khoảng lặng nhỏ cũng giúp bạn thấy nhẹ hơn. ' +
            'Bạn không cần phải đối mặt một mình.',
          hotlines: [],
          suggestBreathing: true,
          suggestEmergencyContact: false,
        };

      case 'medium':
        return {
          message:
            'Mình nghe thấy bạn, và mình muốn bạn biết rằng cảm xúc của bạn hoàn toàn có ý nghĩa. ' +
            'Hãy thử nói chuyện với ai đó bạn tin tưởng — một người bạn, người thân, hoặc chuyên gia tư vấn. ' +
            'Dưới đây là những đường dây hỗ trợ luôn sẵn sàng lắng nghe bạn.',
          hotlines: this.getHotlines('VN'),
          suggestBreathing: true,
          suggestEmergencyContact: true,
        };

      case 'high':
        return {
          message:
            'Bạn rất quan trọng, và cuộc sống của bạn có ý nghĩa. ' +
            'Nếu bạn đang trong tình trạng nguy hiểm, xin hãy gọi ngay cho đường dây hỗ trợ hoặc người thân tin tưởng. ' +
            'Bạn không đơn độc — có người sẵn sàng giúp bạn ngay bây giờ.',
          hotlines: this.getHotlines(),
          suggestBreathing: true,
          suggestEmergencyContact: true,
        };
    }
  }

  /**
   * Return crisis hotlines filtered by country. When no country is given,
   * return all known hotlines (Vietnam first).
   */
  getHotlines(countryCode?: string): Hotline[] {
    const all: Hotline[] = [
      // Vietnam
      {
        name: 'Tổng đài Tư vấn Sức khỏe Tâm thần Quốc gia',
        phone: '1800 599 100',
        hours: '24/7',
        country: 'VN',
      },
      {
        name: 'Đường dây nóng Hỗ trợ Tâm lý',
        phone: '1800 599 920',
        hours: '24/7',
        country: 'VN',
      },
      // United States
      {
        name: '988 Suicide & Crisis Lifeline',
        phone: '988',
        hours: '24/7',
        country: 'US',
      },
      {
        name: 'Crisis Text Line',
        phone: 'Text HOME to 741741',
        hours: '24/7',
        country: 'US',
      },
      // United Kingdom
      {
        name: 'Samaritans',
        phone: '116 123',
        hours: '24/7',
        country: 'UK',
      },
    ];

    if (!countryCode) return all;

    return all.filter(
      (h) => h.country.toUpperCase() === countryCode.toUpperCase(),
    );
  }

  /**
   * Standard safety disclaimer that must be shown alongside any AI-generated
   * wellness content.
   */
  getSafetyDisclaimer(): { disclaimer: string } {
    return {
      disclaimer:
        'App Relax cung cấp các công cụ hỗ trợ thư giãn và chăm sóc sức khỏe tinh thần. ' +
        'App này KHÔNG thay thế cho việc tư vấn, chẩn đoán hoặc điều trị từ chuyên gia tâm lý hoặc y tế. ' +
        'Nếu bạn đang trong tình trạng khẩn cấp về sức khỏe tâm thần, vui lòng liên hệ đường dây nóng hỗ trợ ' +
        'hoặc đến cơ sở y tế gần nhất.',
    };
  }
}
