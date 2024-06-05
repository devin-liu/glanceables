import SwiftUI

struct URLModalView: View {
    @Binding var showingURLModal: Bool
    @Binding var urlString: String
    @Binding var isURLValid: Bool
    @Binding var urls: [String]
    @Binding var selectedURLIndex: Int?
    @Binding var isEditing: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(isEditing ? "Edit URL" : "Add a new URL")) {
                    TextField("Enter URL here", text: $urlString)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                Section {
                    if !isURLValid && !urlString.isEmpty {
                        Text("Invalid URL").foregroundColor(.red)
                    }
                    Button("Save") {
                        validateURL()
                        if isURLValid && !urlString.isEmpty {
                            if isEditing, let index = selectedURLIndex {
                                urls[index] = urlString
                            } else {
                                urls.append(urlString)
                            }
                            resetModalState()
                        }
                    }
                }
            }
            .navigationBarTitle(isEditing ? "Edit URL" : "New URL", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                resetModalState()
            })
        }
    }
    
    private func validateURL() {
        isURLValid = URL(string: urlString) != nil
    }
    
    private func resetModalState() {
        showingURLModal = false
        urlString = ""
        isEditing = false
        selectedURLIndex = nil
        isURLValid = true // Reset to true so the error message won't persist across different uses of the modal
    }
}

struct URLModalView_Previews: PreviewProvider {
    static var previews: some View {
        URLModalView(showingURLModal: .constant(true), urlString: .constant(""), isURLValid: .constant(true), urls: .constant([]), selectedURLIndex: .constant(nil), isEditing: .constant(false))
    }
}
