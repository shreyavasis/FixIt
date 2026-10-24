//
//  ReportFormView.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 10/24/26.
//

import SwiftUI
import SwiftData

struct ReportFormView: View{
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ReportFormViewModel()
    
    var body: some View {
        Form{
            Section("Issue Category"){
                Picker("Category", selection: $viewModel.category){
                    Text("Select a category").tag("")
                    
                    ForEach(viewModel.categories, id: \.self){ category in
                        Text(category).tag(category)
                    }
                }
            }
            Section("Description"){
                TextField("Describe the problem", text: $viewModel.description, axis: .vertical)
                    .lineLimit(4...8)
            }
            Section{
                Button{
                    viewModel.saveReport(context: modelContext)
                } label: {
                    Label("Submit Report", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity)
                }
            }footer:{
                Text("Location capture will be added later")
            }
        }
        .navigationTitle("New Report")
        .alert("FixItLocal", isPresented: $viewModel.showAlert){
            Button("Ok", role: .cancel){}
        }message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview{
    NavigationStack{
        ReportFormView()
    }
    .modelContainer(for: Report.self, inMemory: true)
}
