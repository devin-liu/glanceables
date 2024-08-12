import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    private var webClipManager = WebClipManagerViewModel()
    
    var body: some View {
        NavigationStack{
            VStack {
                BlackMenuBarView(viewModel: webClipManager)
                ScrollView {
                    Text("Glanceables")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(Color.black)
                    if webClipManager.webClips.isEmpty {
                        emptyStateView
                    } else {
                        WebClipGridView(webClipManager: webClipManager)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.85))
            }
        }
    }
    
    var emptyStateView: some View {
        VStack {
            Spacer()
            CreateButtonView()
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
