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

                Picker("Location", selection: $viewModel.locationMode) {
                    Text("Current Location").tag(ReportFormViewModel.LocationMode.current)
                    Text("Type Address").tag(ReportFormViewModel.LocationMode.typed)
                }
                .pickerStyle(.segmented)

                if viewModel.locationMode == .current {

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

                } else {

                    TextField(
                        "e.g. 1151 S Forest Ave, Tempe, AZ",
                        text: $viewModel.typedAddress
                    )
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await viewModel.lookUpTypedAddress() }
                    }

                    Button {
                        Task { await viewModel.lookUpTypedAddress() }
                    } label: {
                        Label("Find Address", systemImage: "magnifyingglass")
                    }
                    .disabled(viewModel.isLoadingAddress)

                    if let latitude = viewModel.typedLatitude,
                       let longitude = viewModel.typedLongitude {
                        Label(
                            "Address found",
                            systemImage: "mappin.circle.fill"
                        )
                        .foregroundStyle(.green)

                        Text("Latitude: \(latitude)")
                            .font(.caption)

                        Text("Longitude: \(longitude)")
                            .font(.caption)
                    }
                }

                // Display address returned by Web API
                if viewModel.isLoadingAddress {
                    ProgressView("Finding address...")
                } else if !viewModel.address.isEmpty {
                    Text(viewModel.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .task(id: locationService.location?.timestamp) {
                if viewModel.locationMode == .current,
                   let location = locationService.location {
                    await viewModel.fetchAddress(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
            .onChange(of: viewModel.locationMode) { _, newMode in
                // Show the address that matches the selected mode
                viewModel.address = ""
                viewModel.clearTypedLocation()

                if newMode == .current, let location = locationService.location {
                    Task {
                        await viewModel.fetchAddress(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    }
                }
            }
            .onChange(of: viewModel.typedAddress) {
                // Editing the text means the old search result no longer applies
                if viewModel.typedLatitude != nil {
                    viewModel.clearTypedLocation()
                    viewModel.address = ""
                }
            }

            Section {
                Button {
                    // Use the typed address's coordinates or the GPS location
                    let usingTyped = viewModel.locationMode == .typed

                    let saved = viewModel.saveReport(
                        context: modelContext,
                        latitude: usingTyped
                            ? viewModel.typedLatitude
                            : locationService.location?.coordinate.latitude,
                        longitude: usingTyped
                            ? viewModel.typedLongitude
                            : locationService.location?.coordinate.longitude,
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
