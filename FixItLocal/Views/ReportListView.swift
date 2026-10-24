//
//  ReportListView.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 10/24/26.
//

import SwiftUI
import SwiftData

struct ReportListView: View {
    @Query(sort: \Report.dateReported, order: .reverse)
    private var reports: [Report]
    
    var body: some View {
        List{
            if reports.isEmpty {
                ContentUnavailableView("No Reports Yet", systemImage: "tray", description: Text("Open New Report to report a community problem"))
            }else{
                ForEach(reports) { report in
                    NavigationLink {
                        ReportDetailView(report: report)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(report.category)
                                .font(.headline)
                            
                            Text(report.reportDescription)
                                .lineLimit(2)
                            
                            HStack {
                                Text(
                                    report.dateReported,
                                    format: .dateTime.month().day().year()
                                )
                                
                                Spacer()
                                
                                Text(report.status)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        ReportListView()
    }
    .modelContainer(for: Report.self, inMemory: true)
}
