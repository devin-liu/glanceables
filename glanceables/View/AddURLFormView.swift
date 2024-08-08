import SwiftUI

struct AddURLFormView: View {
    @ObservedObject var viewModel: WebClipCreatorViewModel
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        HStack {
            TextField("Search or enter website name", text: $viewModel.urlString)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .onChange(of: viewModel.urlString, {
                    debounceValidation()
                    viewModel.showValidationError = false
                })
            
            if viewModel.urlString != "" {
                Button(action: viewModel.clearTextField) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            } else {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            if !viewModel.isURLValid && viewModel.showValidationError && !viewModel.urlString.isEmpty {
                Text("Invalid URL")
                    .foregroundColor(.red)
            }
        }
        .multilineTextAlignment(.center)
        .frame(width: UIScreen.main.bounds.width * 0.7)
        .padding(.vertical, 5)
        .padding(.horizontal, 20)
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray3), lineWidth: 1)
        )
        .onAppear {
            if !viewModel.urlString.isEmpty {
                debounceValidation()
            }
        }.onDisappear {
            print("AddURLFOrmView ", viewModel.urlString, viewModel.validURL, viewModel.validURLs)
        }
    }
    
    private func debounceValidation() {
        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem {
            viewModel.validateURL()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: debounceWorkItem!)
        viewModel.showValidationError = true
    }
}

struct AddURLFormView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AddURLFormView(viewModel: WebClipCreatorViewModel())
                .previewLayout(.sizeThatFits)
                .padding()
            
            Spacer()
        }
    }
}
