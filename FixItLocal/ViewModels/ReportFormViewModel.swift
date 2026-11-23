//
//  ReportFormViewModel.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 10/24/26.
//

import Foundation
import Combine
import SwiftData

class ReportFormViewModel: ObservableObject {

    let categories = [
        "Pothole",
        "Broken Streetlight",
        "Fallen Tree",
        "Other"
    ]

    @Published var category = ""
    @Published var description = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var address = ""
    @Published var isLoadingAddress = false

    // Choose between GPS location and a typed-in address
    enum LocationMode {
        case current
        case typed
    }

    @Published var locationMode: LocationMode = .current
    @Published var typedAddress = ""
    @Published var typedLatitude: Double?
    @Published var typedLongitude: Double?

    private let geocodingService = GeocodingService()

    @MainActor
    func saveReport(
        context: ModelContext,
        latitude: Double?,
        longitude: Double?,
        address: String?
    ) -> Bool {

        let trimmedDescription = description.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard categories.contains(category) else {
            alertMessage = "Please select a category."
            showAlert = true
            return false
        }

        guard !trimmedDescription.isEmpty else {
            alertMessage = "Please provide a description."
            showAlert = true
            return false
        }

        let report = Report(
            category: category,
            reportDescription: trimmedDescription,
            latitude: latitude,
            longitude: longitude,
            address: address
        )

        context.insert(report)

        do {
            try context.save()

            category = ""
            description = ""
            self.address = ""
            typedAddress = ""
            clearTypedLocation()

            alertMessage = "Report submitted successfully!"
            showAlert = true

            return true

        } catch {
            context.delete(report)

            alertMessage = "Failed to submit report: \(error.localizedDescription)"
            showAlert = true

            return false
        }
    }

    @MainActor
    func fetchAddress(
        latitude: Double,
        longitude: Double
    ) async {

        isLoadingAddress = true
        address = ""

        defer {
            isLoadingAddress = false
        }

        do {
            address = try await geocodingService.getAddress(
                latitude: latitude,
                longitude: longitude
            )
        } catch {
            address = ""
            print("Geocoding API error: \(error)")
        }
    }


    /// Looks up the address the user typed and stores its coordinates.
    @MainActor
    func lookUpTypedAddress() async {

        let query = typedAddress.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            alertMessage = "Please type an address first."
            showAlert = true
            return
        }

        isLoadingAddress = true
        clearTypedLocation()
        address = ""

        defer {
            isLoadingAddress = false
        }

        do {
            let result = try await geocodingService.searchAddress(query)
            typedLatitude = result.latitude
            typedLongitude = result.longitude
            address = result.address
        } catch {
            alertMessage = "Couldn't find that address. Try adding the city and state."
            showAlert = true
            print("Address search error: \(error)")
        }
    }

    func clearTypedLocation() {
        typedLatitude = nil
        typedLongitude = nil
    }
}
