import Foundation
import SwiftUI

class AddURLFormViewModel: ObservableObject {
    @Published var urlString: String = ""
    @Published var isURLValid: Bool = true
    @Published var showValidationError: Bool = false
    
    private let webClipEditorViewModel = WebClipEditorViewModel.shared
    
    func validateURL() {
        let (isValid, url) = URLUtilities.validateURL(from: urlString)
        isURLValid = isValid
        if let url = url {
            if webClipEditorViewModel.validURLs.isEmpty {
                webClipEditorViewModel.validURLs.append(url)
                webClipEditorViewModel.selectedValidURLIndex = 0
            } else {
                webClipEditorViewModel.updateOrAddValidURL(url)
            }
        }
    }
    
    func clearTextField() {
        urlString = ""
    }
}
