import SwiftUI

struct BlackEditMenuBarView: View {
    var body: some View {
        HStack {
            Spacer()            
                CaptureModeToggleView()
                    .padding(.trailing, 24)
            
        }
        .padding()
        .background(Color.black) // Black background for the menu bar
    }
}

struct BlackEditMenubarView_Previews: PreviewProvider {
    static var previews: some View {
        BlackEditMenuBarView()
            .frame(maxHeight: .infinity, alignment: .top)
    }
}
