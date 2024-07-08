import SwiftUI

struct AddURLFormView: View {
    @ObservedObject var viewModel: WebClipEditorViewModel
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        Form {
            Section(header: Text(viewModel.isEditing ? "Edit URL" : "Add a new URL")) {
                TextField("Enter URL here", text: $viewModel.urlString)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .onChange(of: viewModel.urlString, {
                        debounceValidation()
                    })
            }            
        }
    }
    
    private func debounceValidation() {
        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem {
            viewModel.validateURL()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: debounceWorkItem!)
    }        
}
