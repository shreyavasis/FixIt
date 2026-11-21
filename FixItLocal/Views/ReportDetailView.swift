
//
//  ReportDetailView.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 10/24/26.
//

import SwiftUI

struct ReportDetailView: View {

    let report: Report

    var body: some View {
        List {

            Section("Category") {
                Text(report.category)
            }

            Section("Description") {
                Text(report.reportDescription)
            }

            Section("Date Reported") {
                Text(
                    report.dateReported,
                    format: .dateTime
                        .month(.wide)
                        .day()
                        .year()
                        .hour()
                        .minute()
                )
            }

            Section("Status") {
                Text(report.status)
            }


            Section("Location") {

                // Readable address from Web API
                if let address = report.address,
                   !address.isEmpty {

                    Label(address, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(.primary)
                }

                // GPS coordinates
                if let latitude = report.latitude,
                   let longitude = report.longitude {

                    Text("Latitude: \(latitude)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Longitude: \(longitude)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                } else {
                    Text("Location was not captured for this report.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Report Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
