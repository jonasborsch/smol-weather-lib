
public struct WeatherData : Decodable {
    let main: WeatherMain
    let wind: Wind
}

public struct WeatherMain : Decodable {
    let feels_like: Double
    let humidity: Int8
    let pressure: Int16
    let temp: Double
    let temp_max: Double
    let temp_min: Double
}

public struct Wind : Decodable {
    let speed: Float
    let deg: Int16
}

public struct Coordinates {
    let lat, lon: Float
}
