
//
//  LocationService.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 11/18/26.
//

import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        authorizationStatus = locationManager.authorizationStatus

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Request Location
    func requestLocation() {
        print("LOCATION: Button triggered")

        switch locationManager.authorizationStatus {

        case .notDetermined:
            print("LOCATION: Requesting permission")
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            print("LOCATION: Permission granted, requesting location")
            locationManager.requestLocation()

        case .denied, .restricted:
            print("LOCATION: Permission denied or restricted")

        @unknown default:
            print("LOCATION: Unknown authorization status")
        }
    }

    // MARK: - Reset Location
    func resetLocation() {
        location = nil
    }

    // MARK: - Authorization Changes
    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        authorizationStatus = manager.authorizationStatus

        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {

            manager.requestLocation()
        }
    }

    // MARK: - Location Updates
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latestLocation = locations.last else {
            print("LOCATION: No coordinates returned")
            return
        }

        location = latestLocation

        print("LOCATION: Latitude = \(latestLocation.coordinate.latitude)")
        print("LOCATION: Longitude = \(latestLocation.coordinate.longitude)")
    }

    // MARK: - Location Errors
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("LOCATION ERROR: \(error.localizedDescription)")
    }
}
