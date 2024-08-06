import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var dashboard = DashboardViewModel.shared
    
    var body: some View {
        NavigationStack{
            VStack {
                BlackMenuBarView(viewModel: dashboard)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                        Text("Glanceables")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                        if dashboard.webClips.isEmpty {
                            emptyStateView
                        } else {
                            urlGrid
                        }
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
    
    var urlGrid: some View {
        ForEach(dashboard.webClips) { item in
            WebGridSingleSnapshotView(id: item.id)
                .onDrag {
                    self.dashboard.draggedItem = item
                    return NSItemProvider(object: item.url.absoluteString as NSString)
                }
                .onDrop(of: [UTType.text], delegate: DropViewDelegate(item: item, viewModel: $dashboard.webClips, draggedItem: $dashboard.draggedItem))
                .contextMenu {
                    NavigationLink(destination: WebClipEditorView(webClip: item)) {
                        Text("Edit")
                    }
                    Button("Delete") {
                        dashboard.deleteItem(item: item)
                    }
                }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: WebClip
    @Binding var viewModel: [WebClip]
    @Binding var draggedItem: WebClip?
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem, draggedItem.id != item.id else { return }
        
        if let fromIndex = viewModel.firstIndex(where: { $0.id == draggedItem.id }),
           let toIndex = viewModel.firstIndex(where: { $0.id == item.id }) {
            withAnimation {
                viewModel.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
