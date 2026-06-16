import type { TranslationKey } from '@/lib/i18n/dictionaries';
import type { TranslationFn, WeatherCurrent, ForecastDay } from './weather-types';

export function buildAdvice(
  current: WeatherCurrent | null,
  today: ForecastDay | undefined,
  t: TranslationFn,
): string[] {
  if (!current || current.configured === false) {
    return [
      t('weather.advice.needLocation'),
      t('weather.advice.needLocationAction'),
    ];
  }
  const tips: string[] = [];
  const temp = current.current?.temperature;
  const apparent = current.current?.apparentTemperature ?? temp;
  const isDay = current.current?.isDay ?? true;
  const humidity = current.current?.humidity ?? 0;
  const wind = current.current?.windSpeed ?? 0;
  const rainChance = today?.precipitationProbability ?? 0;
  const code = current.current?.weatherCode;
  const todayHigh = today?.temperatureMax;
  const todayLow = today?.temperatureMin;
  const now = new Date();
  const hour = now.getHours();
  const day = now.getDay(); // 0=Sun ... 6=Sat
  const isWeekend = day === 0 || day === 6;
  const month = now.getMonth() + 1;

  // ---- Temperature buckets ------------------------------------------------
  if (temp != null) {
    if (temp >= 36) {
      tips.push(t('weather.advice.temp.extreme'));
      tips.push(t('weather.advice.temp.water'));
    } else if (temp >= 33) {
      tips.push(t('weather.advice.temp.hot'));
      tips.push(t('weather.advice.temp.lightLunch'));
    } else if (temp >= 28) {
      tips.push(t('weather.advice.temp.warm'));
    } else if (temp >= 24) {
      tips.push(t('weather.advice.temp.comfort'));
    } else if (temp >= 20) {
      tips.push(t('weather.advice.temp.cool'));
    } else if (temp >= 16) {
      tips.push(t('weather.advice.temp.chilly'));
    } else if (temp >= 10) {
      tips.push(t('weather.advice.temp.cold'));
    } else {
      tips.push(t('weather.advice.temp.freezing'));
    }
  }

  // ---- Apparent vs actual -------------------------------------------------
  if (apparent != null && temp != null && Math.abs(apparent - temp) >= 3) {
    const direction = apparent > temp ? t('weather.advice.apparent.hotter') : t('weather.advice.apparent.cooler');
    tips.push(
      t('weather.advice.apparent', { apparent: Math.round(apparent), direction, temp: Math.round(temp) }),
    );
  }

  // ---- Day temp swing -----------------------------------------------------
  if (todayHigh != null && todayLow != null && todayHigh - todayLow >= 10) {
    tips.push(
      t('weather.advice.swing', { low: Math.round(todayLow), high: Math.round(todayHigh) }),
    );
  }

  // ---- Rain ---------------------------------------------------------------
  if (rainChance >= 80) {
    tips.push(t('weather.advice.rain.veryHigh', { percent: Math.round(rainChance) }));
    tips.push(t('weather.advice.rain.flood'));
  } else if (rainChance >= 60) {
    tips.push(t('weather.advice.rain.high', { percent: Math.round(rainChance) }));
  } else if (rainChance >= 40) {
    tips.push(t('weather.advice.rain.scattered'));
  } else if (rainChance >= 20) {
    tips.push(t('weather.advice.rain.low'));
  }

  // ---- Humidity -----------------------------------------------------------
  if (humidity >= 90) {
    tips.push(t('weather.advice.humidity.veryHigh'));
  } else if (humidity >= 80) {
    tips.push(t('weather.advice.humidity.high'));
  } else if (humidity <= 30) {
    tips.push(t('weather.advice.humidity.dry'));
  } else if (humidity <= 45) {
    tips.push(t('weather.advice.humidity.slightDry'));
  }

  // ---- Wind ---------------------------------------------------------------
  if (wind >= 50) {
    tips.push(t('weather.advice.wind.veryStrong', { wind: Math.round(wind) }));
  } else if (wind >= 30) {
    tips.push(t('weather.advice.wind.strong', { wind: Math.round(wind) }));
  } else if (wind >= 15) {
    tips.push(t('weather.advice.wind.light'));
  }

  // ---- Storm / specific weather codes -------------------------------------
  if (code != null && code >= 95) {
    tips.push(t('weather.advice.code.storm'));
  }
  if (code != null && code >= 45 && code <= 48) {
    tips.push(t('weather.advice.code.fog'));
  }
  if (code != null && code >= 80 && code <= 82) {
    tips.push(t('weather.advice.code.showers'));
  }

  // ---- Time of day --------------------------------------------------------
  if (hour >= 5 && hour < 9) {
    tips.push(t('weather.advice.time.morning'));
  } else if (hour >= 11 && hour < 14) {
    tips.push(t('weather.advice.time.noon'));
  } else if (hour >= 14 && hour < 17) {
    tips.push(t('weather.advice.time.afternoon'));
  } else if (hour >= 17 && hour < 20) {
    tips.push(t('weather.advice.time.evening'));
  } else if (hour >= 20 && hour < 23) {
    tips.push(t('weather.advice.time.night'));
  } else if (hour >= 23 || hour < 5) {
    tips.push(t('weather.advice.time.late'));
  }

  // ---- Weekend / weekday --------------------------------------------------
  if (isWeekend) {
    tips.push(t('weather.advice.weekend'));
  } else {
    tips.push(t('weather.advice.weekday'));
  }

  // ---- Seasonal hints (VN miền Nam) ---------------------------------------
  if (month >= 5 && month <= 10) {
    tips.push(t('weather.advice.season.rainy'));
  } else if (month >= 11 || month <= 2) {
    tips.push(t('weather.advice.season.dry'));
  } else {
    tips.push(t('weather.advice.season.transition'));
  }

  // ---- Day/night ----------------------------------------------------------
  if (!isDay) {
    tips.push(t('weather.advice.dayNight.night'));
  } else if (temp != null && temp >= 28) {
    tips.push(t('weather.advice.dayNight.sun'));
  }

  // ---- Always-on mindfulness ---------------------------------------------
  tips.push(t('weather.advice.mindfulness'));

  return tips;
}

export function buildWeatherGreeting(current: WeatherCurrent | null, t: TranslationFn) {
  if (!current) {
    return { title: t('common.loading'), subtitle: '—' };
  }
  if (current.configured === false) {
    return {
      title: t('weather.missing.title'),
      subtitle: t('weather.missing.copy'),
    };
  }

  const temp = current.current?.temperature;
  const code = current.current?.weatherCode;
  const isDay = current.current?.isDay;
  const hour = new Date().getHours();
  const period =
    hour >= 23 || hour < 5
      ? 'late'
      : hour < 11
        ? 'morning'
        : hour < 17
          ? 'day'
          : hour < 21
            ? 'evening'
            : 'night';
  const condition = describeWeatherCode(code, isDay, t).toLowerCase();
  const tempLabel = temp == null ? '' : t('weather.greeting.temp', { temp: Math.round(temp) });

  return {
    title: t(`weather.greeting.${period}` as TranslationKey),
    subtitle: tempLabel
      ? t('weather.greeting.subtitleWithTemp', { condition, temp: tempLabel })
      : t('weather.greeting.subtitle', { condition }),
  };
}

export function describeWeatherCode(code: number | undefined, isDay: boolean | undefined, t: TranslationFn): string {
  // Open-Meteo WMO weather codes — abbreviated for the UI.
  if (code == null) return '—';
  if (code === 0) return isDay === false ? t('weather.code.clearNight') : t('weather.code.clear');
  if (code <= 2) return t('weather.code.mainlyClear');
  if (code === 3) return t('weather.code.cloudy');
  if (code >= 45 && code <= 48) return t('weather.code.fog');
  if (code >= 51 && code <= 57) return t('weather.code.drizzle');
  if (code >= 61 && code <= 67) return t('weather.code.rain');
  if (code >= 71 && code <= 77) return t('weather.code.snow');
  if (code >= 80 && code <= 82) return t('weather.code.showers');
  if (code >= 85 && code <= 86) return t('weather.code.snowShowers');
  if (code >= 95) return t('weather.code.thunderstorm');
  return '—';
}

export function formatTemp(value: number | undefined): string {
  if (value == null || Number.isNaN(value)) return '—';
  return String(Math.round(value));
}

export function roundTemp(value: number | undefined): number | null {
  if (value == null || Number.isNaN(value)) return null;
  return Math.round(value);
}

export function formatDay(date: string | undefined, locale: string): string {
  if (!date) return '—';
  try {
    const d = new Date(date);
    return d.toLocaleDateString(locale === 'vi' ? 'vi-VN' : 'en-US', { weekday: 'short', day: '2-digit' });
  } catch {
    return date;
  }
}
