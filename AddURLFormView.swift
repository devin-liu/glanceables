import SwiftUI

struct AddURLFormView: View {
    @ObservedObject var viewModel: WebClipEditorViewModel
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        
        
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search or enter website name", text: $viewModel.urlString)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .onChange(of: viewModel.urlString, {
                    debounceValidation()
                })
            
            
            if viewModel.urlString != "" {
                Button(action: clearTextField) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func debounceValidation() {
        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem {
            viewModel.validateURL()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: debounceWorkItem!)
    }
    
    private func clearTextField() {
        viewModel.urlString = ""
    }
}
