
//
//  ReportFormView.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 10/24/26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct ReportFormView: View {

    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = ReportFormViewModel()
    @StateObject private var locationService = LocationService()

    var body: some View {
        Form {

            Section("Issue Category") {
                Picker("Category", selection: $viewModel.category) {
                    Text("Select a category").tag("")

                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }

            Section("Description") {
                TextField(
                    "Describe the problem",
                    text: $viewModel.description,
                    axis: .vertical
                )
                .lineLimit(4...8)
            }
            Section("Location") {

                if let location = locationService.location {
                    Label(
                        "Location captured",
                        systemImage: "location.fill"
                    )
                    .foregroundStyle(.green)

                    Text("Latitude: \(location.coordinate.latitude)")
                        .font(.caption)

                    Text("Longitude: \(location.coordinate.longitude)")
                        .font(.caption)
                }

                // Display address returned by Web API
                if viewModel.isLoadingAddress {
                    ProgressView("Finding address...")
                } else if !viewModel.address.isEmpty {
                    Text(viewModel.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button {
                    locationService.requestLocation()
                } label: {
                    Label(
                        locationService.location == nil
                            ? "Use Current Location"
                            : "Update Current Location",
                        systemImage: "location"
                    )
                }
            }
            .task(id: locationService.location?.timestamp) {
                if let location = locationService.location {
                    await viewModel.fetchAddress(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }

            Section {
                Button {
                    let saved = viewModel.saveReport(
                        context: modelContext,
                        latitude: locationService.location?.coordinate.latitude,
                        longitude: locationService.location?.coordinate.longitude,
                        address: viewModel.address.isEmpty
                            ? nil
                            : viewModel.address
                    )

                    if saved {
                        locationService.resetLocation()
                    }

                } label: {
                    Label(
                        "Submit Report",
                        systemImage: "paperplane.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.isLoadingAddress)
            }
        }
        .navigationTitle("New Report")
        .alert(
            "FixItLocal",
            isPresented: $viewModel.showAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview {
    NavigationStack {
        ReportFormView()
    }
    .modelContainer(for: Report.self, inMemory: true)
}
