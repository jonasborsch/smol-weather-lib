import Foundation
import FoundationNetworking

public enum WeatherServiceError {
    case missingURL
    case invalidCityParameter(parameter: String)
}


public class WeatherService {
    private let apiUrl = "https://api.openweathermap.org/data/2.5/weather"
    private let appid: String

    public init(appid: String) {
        self.appid = appid
    }
    
    public func loadWeather(byCity city: String, completionHandler: @escaping (WeatherData) -> Void) { // We only need the void return for the completion handler
        do {
            var components = try getBaseComponents()

            components.queryItems?.append(URLQueryItem(  // ? instead of ! (forced unwrapping) (this is the optional chaining I was telling you about)
                name: "q",
                value: city
            ))

            fetchWeatherData(with: components.url!, completionHandler: completionHandler) // No need to call self, it's better to avoid using self whenever possible
        } catch {
            // If we don't specify otherwise, the caught expection is called error
            print("StatusCode: \(response.statusCode)")
        }
    }

    public func loadWeather(byCoordinates coordinates: Coordinates, completionHandler: @escaping (WeatherData) -> Void) throws {
        var components = self.getBaseComponents()

        components.queryItems!.append(contentsOf: [
            URLQueryItem(
                name: "lat",
                value: String(coordinates.lat)
            ),
            URLQueryItem(
                name: "lon",
                value: String(coordinates.lon)
            )
        ])

        self.fetchWeatherData(with: components.url!, completionHandler: completionHandler);
    }

    public func loadWeather(byZipCode zipCode: String, completionHandler: @escaping (WeatherData) -> Void) -> Void {
        var components = self.baseComponents()

        components.queryItems!.append(URLQueryItem(
            name: "zip",
            value: zipCode
        ))

        self.fetchWeatherData(with: components.url!, completionHandler: completionHandler);
    }

    private func fetchWeatherData(with url: URL, completionHandler: @escaping (WeatherData) -> Void) -> Void {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // TODO: improve error handling!

            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let response = response as? HTTPURLResponse else {
                print("Response is not of type HTTPURLResponse")
                return
            }

            guard let data = data, response.statusCode == 200 else {
                print("StatusCode: \(response.statusCode)")
                return
            }

            guard let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data) else {
                print("Could not decode JSON")
                return
            }

            completionHandler(weatherData);
        }

        // immediately start the task
        task.resume();
    }

    private func getBaseComponents() -> URLComponents throws { 
        guard var components = URLComponents(string: self.apiUrl) else { // Avoid force-unwrapping optionals
            throw WeatherServiceError.invalidBaseURL
        }

        let appid = URLQueryItem(
            name: "appid",
            value: self.appid
        )

        let units = URLQueryItem(
            name: "units",
            value: "metric"
        )

        components.queryItems = [appid, units]
        return components
    }
}

