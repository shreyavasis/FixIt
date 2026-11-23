//
//  ReportMapViewModel.swift
//  FixItLocal
//

import Foundation
import SwiftUI
import MapKit
import SwiftData
import Combine

/// One pin on the map: a saved report plus its coordinate.
struct ReportPin: Identifiable {
    let report: Report
    let coordinate: CLLocationCoordinate2D

    var id: PersistentIdentifier { report.persistentModelID }
}

@MainActor
class ReportMapViewModel: ObservableObject {

    let categories = ["All", "Pothole", "Broken Streetlight", "Fallen Tree", "Other"]

    // Starts on the user's real location (nothing hardcoded)
    @Published var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var selectedReport: Report?
    @Published var categoryFilter = "All"

    private let locationService = LocationService()

    func onAppear() {
        // Asks for location permission the first time, then gets the current location
        locationService.requestLocation()
    }

    /// Turns saved reports into map pins, using the coordinates stored with each report.
    func pins(from reports: [Report]) -> [ReportPin] {
        reports.compactMap { report in
            guard let latitude = report.latitude,
                  let longitude = report.longitude else { return nil }

            guard categoryFilter == "All" || report.category == categoryFilter else { return nil }

            return ReportPin(
                report: report,
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            )
        }
    }

    /// Zooms the map out so every pin is visible.
    func showAllReports() {
        position = .automatic
    }

    func iconName(for category: String) -> String {
        switch category {
        case "Pothole": return "exclamationmark.triangle.fill"
        case "Broken Streetlight": return "lightbulb.slash.fill"
        case "Fallen Tree": return "tree.fill"
        default: return "wrench.and.screwdriver.fill"
        }
    }

    func color(for category: String) -> Color {
        switch category {
        case "Pothole": return .orange
        case "Broken Streetlight": return .yellow
        case "Fallen Tree": return .green
        default: return .blue
        }
    }
}
