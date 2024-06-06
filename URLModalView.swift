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
                Section(header: Text(isEditing ? "Edit URL" : "Add a new URL").padding(.top, 20)) {
                    TextField("Enter URL here", text: $urlString)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 20)
                }
                Section {
                    if !isURLValid && !urlString.isEmpty {
                        Text("Invalid URL").foregroundColor(.red)
                    }
                    Button("Save") {
                        handleSaveURL()
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitle(isEditing ? "Edit URL" : "New URL", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                resetModalState() // Reset modal state on cancel
            })
            .edgesIgnoringSafeArea(.all) // Ignoring safe area to maximize space usage
        }
    }
    
    private func handleSaveURL(){
        validateURL()
        if isURLValid {
            if !urlString.isEmpty {
                if isEditing, let index = selectedURLIndex {
                    urls[index] = urlString
                } else {
                    urls.append(urlString)
                }
                resetModalState() // Reset modal only on successful save
            }
        }
    }
    
    private func validateURL() {
       if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
           urlString = "https://" + urlString
       }
       isURLValid = canOpenURL(urlString) && isValidURLFormat(urlString)
   }
   
   func canOpenURL(_ string: String?) -> Bool {
       guard let urlString = string, let url = URL(string: urlString) else {
           return false
       }
       return UIApplication.shared.canOpenURL(url)
   }
   
   func isValidURLFormat(_ string: String) -> Bool {
       let regex = "^(https?://)?([\\w\\d-]+\\.)+[\\w\\d-]+/?([\\w\\d-._\\?,'+/&%$#=~]*)*[^.]$"
       return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: string)
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
        URLModalView(showingURLModal: .constant(false), urlString: .constant(""), isURLValid: .constant(true), urls: .constant([]), selectedURLIndex: .constant(nil), isEditing: .constant(false))
    }
}
