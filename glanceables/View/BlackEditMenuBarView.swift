import SwiftUI

struct BlackEditMenuBarView: View {
    var webClipSelector: WebClipSelectorViewModel
    
    var body: some View {
        HStack {
            Spacer()            
                CaptureModeToggleView(viewModel: webClipSelector)
                    .padding(.trailing, 24)
            
        }
        .padding()
        .background(Color.black) // Black background for the menu bar
    }
}

struct BlackEditMenubarView_Previews: PreviewProvider {
    static var previews: some View {
        let webClipSelector = WebClipSelectorViewModel()
        BlackEditMenuBarView(webClipSelector: webClipSelector)
            .frame(maxHeight: .infinity, alignment: .top)
    }
}
