//
//  ReportMapView.swift
//  FixItLocal
//

import SwiftUI
import SwiftData
import MapKit

struct ReportMapView: View {

    @Query(sort: \Report.dateReported, order: .reverse)
    private var reports: [Report]

    @StateObject private var viewModel = ReportMapViewModel()

    var body: some View {
        let pins = viewModel.pins(from: reports)

        Map(position: $viewModel.position) {
            UserAnnotation()

            ForEach(pins) { pin in
                Annotation(pin.report.category, coordinate: pin.coordinate) {
                    Button {
                        viewModel.selectedReport = pin.report
                    } label: {
                        Image(systemName: viewModel.iconName(for: pin.report.category))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(viewModel.color(for: pin.report.category), in: Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .overlay(alignment: .bottom) {
            if pins.isEmpty {
                Text("No reports with a location yet")
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Show All") {
                    viewModel.showAllReports()
                }
                .disabled(pins.isEmpty)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Category", selection: $viewModel.categoryFilter) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .sheet(item: $viewModel.selectedReport) { report in
            NavigationStack {
                ReportDetailView(report: report)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    NavigationStack {
        ReportMapView()
    }
    .modelContainer(for: Report.self, inMemory: true)
}
