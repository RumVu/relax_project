/**
 * Time-of-day greeting strings shown on the dashboard hero.
 * Pure: lấy `displayName` + đồng hồ hệ thống → trả 1 object thân thiện.
 */
export interface Greeting {
  title: string;
  titleTemplate: string;
  displayName: string | null;
  subtitle: string;
  period: 'NIGHT' | 'MORNING' | 'AFTERNOON' | 'EVENING';
  iconKey: string;
}

export function buildGreeting(displayName?: string | null): Greeting {
  const hour = new Date().getHours();
  const normalizedDisplayName = displayName?.trim() || null;
  const name = normalizedDisplayName ?? 'bạn';

  if (hour >= 22 || hour < 5) {
    return {
      title: `Khuya rồi nè, ${name} ơi`,
      titleTemplate: 'Khuya rồi nè, {{name}} ơi',
      displayName: normalizedDisplayName,
      subtitle: 'Đừng thức khuya quá đó nha ~',
      period: 'NIGHT',
      iconKey: 'weather-night',
    };
  }

  if (hour < 11) {
    return {
      title: `Đã trở lại rồi nè, ${name} ~`,
      titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
      displayName: normalizedDisplayName,
      subtitle: 'Trời nắng đẹp ghê!',
      period: 'MORNING',
      iconKey: 'weather-sunny',
    };
  }

  if (hour < 18) {
    return {
      title: 'Chiều rồi nè, nghỉ một chút nha ~',
      titleTemplate: 'Chiều rồi nè, nghỉ một chút nha ~',
      displayName: normalizedDisplayName,
      subtitle: 'Hít nhẹ một hơi rồi mình tiếp tục.',
      period: 'AFTERNOON',
      iconKey: 'weather-cloudy',
    };
  }

  return {
    title: 'Tối rồi nè, mình thả lỏng nha ~',
    titleTemplate: 'Tối rồi nè, mình thả lỏng nha ~',
    displayName: normalizedDisplayName,
    subtitle: 'Một ngày đã đi qua, nghe lòng mình chút nhé.',
    period: 'EVENING',
    iconKey: 'weather-evening',
  };
}
