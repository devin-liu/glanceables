import SwiftUI
import Combine

struct URLModalView: View {
    @Binding var showingURLModal: Bool
    @Binding var urlString: String
    @Binding var isURLValid: Bool
    @Binding var urls: [String]
    @Binding var selectedURLIndex: Int?
    @Binding var isEditing: Bool
    
    @State private var debounceWorkItem: DispatchWorkItem?
    @State private var validURL: URL?
    @State private var pageTitle: String = "Loading..."
    @State private var selectionRectangle: CGRect? // Added this line

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Form {
                        Section(header: Text(isEditing ? "Edit URL" : "Add a new URL").padding(.top, 20)) {
                            TextField("Enter URL here", text: $urlString)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textInputAutocapitalization(.never)
                                .padding(.vertical, 20)
                                .onChange(of: urlString, perform: { newValue in
                                    debounceValidation()
                                })
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
                    .frame(height: geometry.size.height * 0.3)
                    Spacer()
                    if isURLValid, let url = validURL {
                        WebView(url: .constant(url), pageTitle: $pageTitle, selectionRectangle: $selectionRectangle)
                            .frame(height: geometry.size.height * 0.7)
                    }
                }
                .navigationBarTitle(isEditing ? "Edit URL" : "New URL", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    resetModalState()
                })
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private func handleSaveURL() {
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
    
    private func debounceValidation() {
        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem {
            validateURL()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: debounceWorkItem!)
    }

    private func validateURL() {
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        if let url = URL(string: urlString), canOpenURL(urlString) && isValidURLFormat(urlString) {
            isURLValid = true
            validURL = url
        } else {
            isURLValid = false
            validURL = nil
        }
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
        validURL = nil
    }
}
