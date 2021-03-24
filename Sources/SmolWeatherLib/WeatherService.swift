import Foundation
import FoundationNetworking

public enum WeatherServiceError : Error {
    case invalidBaseURL
    case parsingError
    case invalidResponseError
    case HTTPResponseError(response: HTTPURLResponse)
}


public class WeatherService {
    private let apiUrl = "https://api.openweathermap.org/data/2.5/weather"
    private let appid: String

    public init(appid: String) {
        self.appid = appid
    }
    
    public func loadWeather(byCity city: String, completionHandler: @escaping (Result<WeatherData, Error>) -> Void) throws {
        let cityParam = URLQueryItem(
            name: "q",
            value: city
        )
        let components = try generateURL(cityParam)

        fetchWeatherData(with: components.url!, completionHandler: completionHandler)
    }

    public func loadWeather(byCoordinates coordinates: Coordinates, completionHandler: @escaping (Result<WeatherData, Error>) -> Void) throws {
        let latItem = URLQueryItem(
            name: "lat",
            value: String(coordinates.lat)
        )
        let lonItem = URLQueryItem(
            name: "lon",
            value: String(coordinates.lon)
        )
        
        let components = try generateURL(latItem, lonItem)

        fetchWeatherData(with: components.url!, completionHandler: completionHandler);
    }

    public func loadWeather(byZipCode zipCode: String, completionHandler: @escaping (Result<WeatherData, Error>) -> Void) throws {
        let zipItem = URLQueryItem(
            name: "zip",
            value: zipCode
        )
        
        let components = try generateURL(zipItem)

        fetchWeatherData(with: components.url!, completionHandler: completionHandler);
    }

    private func fetchWeatherData(with url: URL, completionHandler: @escaping (Result<WeatherData, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completionHandler(.failure(WeatherServiceError.invalidResponseError))
                return
            }

            if response.statusCode != 200 {
                completionHandler(.failure(WeatherServiceError.HTTPResponseError(response: response)))
                return
            }

            guard let data = data,
                  let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data)
            else {
                completionHandler(.failure(WeatherServiceError.parsingError))
                return
            }

            completionHandler(.success(weatherData));
        }

        // immediately start the task
        task.resume();
    }

    private func generateURL(_ items: URLQueryItem...) throws -> URLComponents { 
        guard var components = URLComponents(string: self.apiUrl) else {
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

        var queryItems = [appid, units]
        queryItems.append(contentsOf: items)
        components.queryItems = queryItems

        return components
    }
}

