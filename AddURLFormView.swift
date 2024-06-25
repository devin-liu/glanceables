import SwiftUI

struct AddURLFormView: View {
    @Binding var urlString: String
    @Binding var validURL: URL?
    @Binding var isURLValid: Bool
    @Binding var isEditing: Bool
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        Form {
            Section(header: Text(isEditing ? "Edit URL" : "Add a new URL")) {
                TextField("Enter URL here", text: $urlString)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .onChange(of: urlString, {
                        debounceValidation()
                    })
            }            
        }
    }
    
    private func debounceValidation() {
        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem {
            validateURL()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: debounceWorkItem!)
    }
    
    private func validateURL() {
        let validation = URLUtilities.validateURL(from: urlString)
        isURLValid = validation.isValid
        if(isURLValid){
            validURL = validation.url
        }
    }
}
