import SwiftUI

struct BlackMenuBarView: View {
    @ObservedObject var viewModel = DashboardViewModel.shared
    
    var body: some View {
        HStack {
            Spacer()            
            NavigationLink(destination: WebClipCreatorView()) {
                Image(systemName: "plus")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black) // Black background for the menu bar
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

struct ParentView: View {
    var viewModel = DashboardViewModel() // Ensure this matches the initialization requirements of your DashboardViewModel
    
    var body: some View {
        BlackMenuBarView(viewModel: viewModel)
            .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ParentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
    }
}
