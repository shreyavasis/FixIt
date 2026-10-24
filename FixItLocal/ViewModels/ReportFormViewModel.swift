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
    let categories = ["Pothole", "Broken Streetlight", "Fallen Tree", "Other"]
    @Published var category = ""
    @Published var description = ""
    
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    @MainActor
    func saveReport(context: ModelContext){
        let trimmedDecription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard categories.contains(category)
        else{
            alertMessage = "Please select a category."
            showAlert = true
            return
        }
        guard !trimmedDecription.isEmpty else {
            alertMessage = "Please provide a description."
            showAlert = true
            return
        }
        
        let report = Report(category: category, reportDescription: trimmedDecription)
        context.insert(report)
        
        do {
            try context.save()
            category = ""
            description = ""
            alertMessage = "Report submitted successfully!"
        }catch {
            context.delete(report)
            alertMessage = "Failed to submit report. Please try again."
        }
        showAlert = true
        }
        
    }
