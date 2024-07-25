import SwiftUI

struct BlackMenuBarView: View {
    @ObservedObject var captureViewModel = DraggableWebCaptureViewModel.shared
    @State private var searchText: String = ""
    @Binding var isShowingModal: Bool  // Use this Binding to control modal visibility from outside
    
    var body: some View {
        HStack {
            Spacer()
            if isShowingModal {
                CaptureModeToggleView(viewModel: captureViewModel)
                    .padding(.trailing, 24)
            }
            Button(action: {
                self.isShowingModal.toggle()  // Toggle the modal visibilityÏÏ
            }) {
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
    @State private var showingAddURLModal = false
    
    var body: some View {
        BlackMenuBarView(isShowingModal: $showingAddURLModal)
            .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ParentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
    }
}
