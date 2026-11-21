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

}
