import 'package:test/test.dart';
import 'package:relax_api_client/relax_api_client.dart';


/// tests for WeatherApi
void main() {
  final instance = RelaxApiClient().getWeatherApi();

  group(WeatherApi, () {
    // Get current weather by coordinates
    //
    //Future<WeatherCurrentResponseDto> weatherControllerGetCurrent({ num latitude, num longitude, String timezone }) async
    test('test weatherControllerGetCurrent', () async {
      // TODO
    });

    // Get weather forecast by coordinates
    //
    //Future<WeatherForecastResponseDto> weatherControllerGetForecast({ num latitude, num longitude, String timezone, num forecastDays }) async
    test('test weatherControllerGetForecast', () async {
      // TODO
    });

    // Get current weather for the current user location
    //
    //Future<WeatherCurrentResponseDto> weatherControllerGetMine({ num latitude, num longitude, String timezone }) async
    test('test weatherControllerGetMine', () async {
      // TODO
    });

    // Get weather forecast for the current user location
    //
    //Future<WeatherForecastResponseDto> weatherControllerGetMyForecast({ num latitude, num longitude, String timezone, num forecastDays }) async
    test('test weatherControllerGetMyForecast', () async {
      // TODO
    });

    // Reverse geocode coordinates into a location name
    //
    //Future<JsonObject> weatherControllerReverseGeocode(num latitude, num longitude, { String localityLanguage }) async
    test('test weatherControllerReverseGeocode', () async {
      // TODO
    });

    // Save current user weather location preferences
    //
    //Future<JsonObject> weatherControllerUpdateMyLocation(UpdateWeatherLocationDto updateWeatherLocationDto) async
    test('test weatherControllerUpdateMyLocation', () async {
      // TODO
    });

  });
}
