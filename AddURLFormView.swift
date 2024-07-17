import SwiftUI

struct AddURLFormView: View {
    @ObservedObject var viewModel: WebClipEditorViewModel
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        HStack {
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
                .padding(.trailing, 10) // Slight padding before the right edge
            }else{
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            if !viewModel.isURLValid && !viewModel.urlString.isEmpty {
                Text("Invalid URL")
                    .foregroundColor(.red)                             
            }
        }
        .multilineTextAlignment(.center)  // Centers the text inside the TextField
        .frame(width: UIScreen.main.bounds.width * 0.7)
        .padding(.vertical, 5)  // Adjust vertical padding to increase height
        .padding(.horizontal, 20)  // Adjust horizontal padding for wider spacing
        .background(Color(.systemGray5))  // Set the background color
        .cornerRadius(10)  // Apply corner radius to smooth the edges
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray3), lineWidth: 1)  // Apply a light gray border
        )
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

struct AddURLFormView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            AddURLFormView(viewModel: WebClipEditorViewModel())
                .previewLayout(.sizeThatFits)
                .padding()
            
            Spacer()
        }
    }
}
