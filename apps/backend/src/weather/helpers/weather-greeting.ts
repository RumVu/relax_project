/**
 * Build the weather-aware greeting card. Pure — needs only timezone +
 * displayName + weather description.
 */
import {
  WeatherDescription,
  describeWeather,
} from './weather-description';

export interface WeatherGreeting {
  title: string;
  titleTemplate: string;
  displayName: string | null;
  subtitle: string;
  iconKey: string;
}

export function buildGreeting(
  weather: WeatherDescription,
  displayName?: string | null,
): WeatherGreeting {
  const name = displayName?.trim() || 'bạn';
  const titleTemplate = weather.titleTemplate ?? weather.title ?? '';

  return {
    title: titleTemplate.replace('{{name}}', name),
    titleTemplate,
    displayName: displayName?.trim() || null,
    subtitle: weather.subtitle,
    iconKey: weather.iconKey,
  };
}

/**
 * Used khi weather chưa configure (LOCATION_MISSING / WEATHER_DISABLED).
 * Pick night vs default-day greeting based on the user's timezone.
 */
export function buildFallbackGreeting(
  timezone: string,
  displayName?: string | null,
): WeatherGreeting {
  const hour = Number(
    new Intl.DateTimeFormat('en-US', {
      hour: '2-digit',
      hourCycle: 'h23',
      timeZone: timezone,
    }).format(new Date()),
  );

  if (hour >= 21 || hour < 5) {
    return buildGreeting(
      describeWeather(0, false), // night
      displayName,
    );
  }

  return buildGreeting(
    {
      titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
      subtitle: 'Hôm nay mình chăm sóc cảm xúc một chút nha.',
      iconKey: 'weather-default',
    },
    displayName,
  );
}
