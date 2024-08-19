import SwiftUI

struct AddURLFormView: View {
    @Bindable var viewModel: WebClipCreatorViewModel
    
    var body: some View {
        HStack {
            urlTextField
            
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
    }
    
    private var urlTextField: some View {
        TextField("Search or enter website name", text: $viewModel.urlString)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            .multilineTextAlignment(.center)
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
