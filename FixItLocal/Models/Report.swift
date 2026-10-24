//
//  Report.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 10/24/26.
//

import Foundation
import SwiftData

@Model
final class Report {
    var category: String
    var reportDescription: String
    var dateReported: Date
    var status: String
    var latitude: Double?
    var longitude: Double?
    
    init(
        category: String,
        reportDescription: String,
        dateReported: Date = Date(),
        status: String = "Submitted",
        latitude: Double? = nil,
        longitude: Double? = nil
    ){
        self.category = category
        self.reportDescription = reportDescription
        self.dateReported = dateReported
        self.status = status
        self.latitude = latitude
        self.longitude = longitude
    }
}
