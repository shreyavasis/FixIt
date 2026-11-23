//
//  GeocodingService.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 11/21/26.
//


import Foundation

struct AddressResponse: Decodable {
    let address: AddressDetails?
}

struct AddressDetails: Decodable {
    let city: String?
    let town: String?
    let village: String?
    let state: String?
    let country: String?
}

// One result from the Nominatim search API (address -> coordinates).
// Nominatim returns lat/lon as strings, so they are converted to Double below.
struct SearchResult: Decodable {
    let lat: String
    let lon: String
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case displayName = "display_name"
    }
}

enum GeocodingError: Error {
    case invalidURL
    case invalidResponse
    case noResults
}

class GeocodingService {

    func getAddress(
        latitude: Double,
        longitude: Double
    ) async throws -> String {

        var components = URLComponents(
            string: "https://nominatim.openstreetmap.org/reverse"
        )

        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "addressdetails", value: "1")
        ]

        guard let url = components?.url else {
            throw GeocodingError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(
            "FixItLocal/1.0 (student project; contact: https://github.com/shreyavasis/FixIt)",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GeocodingError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(
            AddressResponse.self,
            from: data
        )

        let address = decoded.address
        let city = address?.city
            ?? address?.town
            ?? address?.village
            ?? "Unknown City"

        let state = address?.state ?? ""
        let country = address?.country ?? ""

        return [city, state, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    /// Looks up a typed address and returns its coordinates (forward geocoding).
    func searchAddress(
        _ query: String
    ) async throws -> (latitude: Double, longitude: Double, address: String) {

        var components = URLComponents(
            string: "https://nominatim.openstreetmap.org/search"
        )

        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "limit", value: "1")
        ]

        guard let url = components?.url else {
            throw GeocodingError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(
            "FixItLocal/1.0 (student project; contact: https://github.com/shreyavasis/FixIt)",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GeocodingError.invalidResponse
        }

        let results = try JSONDecoder().decode(
            [SearchResult].self,
            from: data
        )

        guard let first = results.first,
              let latitude = Double(first.lat),
              let longitude = Double(first.lon) else {
            throw GeocodingError.noResults
        }

        return (latitude, longitude, first.displayName)
    }
}
