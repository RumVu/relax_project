/**
 * Map an Open-Meteo WMO weather code into Vietnamese title/subtitle/icon
 * the dashboard renders. Pure lookup; safe for use everywhere.
 *
 * Codes: https://open-meteo.com/en/docs#weathervariables
 *   0-1  clear/mainly clear
 *   51-67 drizzle/rain
 *   80-99 thunderstorm/shower
 *   everything else → cloudy default
 */
export interface WeatherDescription {
  title?: string;
  titleTemplate?: string;
  subtitle: string;
  iconKey: string;
}

export function describeWeather(
  code: number,
  isDay: boolean,
): WeatherDescription {
  if (!isDay) {
    return {
      titleTemplate: 'Khuya rồi nè, {{name}} ơi',
      subtitle: 'Đừng thức khuya quá đó nha ~',
      iconKey: 'weather-night',
    };
  }

  if (code === 0 || code === 1) {
    return {
      titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
      subtitle: 'Trời nắng đẹp ghê!',
      iconKey: 'weather-sunny',
    };
  }

  if (code >= 51 && code <= 67) {
    return {
      title: 'Mưa nhẹ ngoài kia rồi nè',
      subtitle: 'Ở yên một chút cho lòng dịu lại nha ~',
      iconKey: 'weather-rain',
    };
  }

  if (code >= 80 && code <= 99) {
    return {
      title: 'Trời đang hơi ồn ào đó',
      subtitle: 'Mình chậm lại một nhịp nha ~',
      iconKey: 'weather-storm',
    };
  }

  return {
    titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
    subtitle: 'Thời tiết hôm nay cũng hợp để chill đó.',
    iconKey: 'weather-cloudy',
  };
}

/**
 * Short label for a forecast card. Uses the description's `title` if
 * present, otherwise picks one from the iconKey family.
 */
export function buildForecastTitle(weather: {
  title?: string;
  iconKey: string;
}): string {
  if (weather.title) return weather.title;
  if (weather.iconKey === 'weather-sunny') return 'Trời nắng đẹp';
  if (weather.iconKey === 'weather-night') return 'Trời đã về khuya';
  if (weather.iconKey === 'weather-cloudy') return 'Trời dịu nhẹ';
  return 'Thời tiết hôm nay';
}
