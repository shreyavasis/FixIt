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
        List{
            Section("Category"){
                Text(report.category)
            }
            
            Section("Description"){
                Text(report.reportDescription)
            }
            
            Section("Date Reported"){
                Text(report.dateReported, format: .dateTime.month(.wide).day().year().hour().minute())
            }
            Section("Status"){
                Text(report.status)
            }
            Section("Location"){
                if let latitude = report.latitude,
                    let longitude = report.longitude {
                    Text("Latitude: \(latitude)")
                    Text("Longitude: \(longitude)")
                }else{
                    Text("Location was not captured for this report.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Report Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
