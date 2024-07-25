import SwiftUI

struct NavigationButtonsView: View {
    @ObservedObject var viewModel: WebClipEditorViewModel  // Use the ViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                navigateBack()
            }) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canNavigateBack())  // Disable button when not applicable
            
            Button(action: {
                navigateForward()
            }) {
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!canNavigateForward())  // Disable button when not applicable
        }
    }
    
    private func navigateBack() {
        if let index = viewModel.selectedValidURLIndex, index > 0 {
            viewModel.selectedValidURLIndex = index - 1
            // Additional actions like loading the selected URL in the WebView can be handled here
        }
    }
    
    private func navigateForward() {
        if let index = viewModel.selectedValidURLIndex, index < viewModel.validURLs.count - 1 {
            viewModel.selectedValidURLIndex = index + 1
            // Additional actions like loading the selected URL in the WebView can be handled here
        }
    }
    
    private func canNavigateBack() -> Bool {
        if let index = viewModel.selectedValidURLIndex {
            return index > 0
        }
        return false
    }
    
    private func canNavigateForward() -> Bool {
        if let index = viewModel.selectedValidURLIndex {
            return index < viewModel.validURLs.count - 1
        }
        return false
    }
}

// Example Preview (Assuming you have the ViewModel setup)
struct NavigationButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationButtonsView(viewModel: WebClipEditorViewModel.shared)
    }
}
