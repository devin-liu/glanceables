import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var contentViewModel = DashboardViewModel.shared
    
    var body: some View {
        NavigationStack{
            VStack {
                BlackMenuBarView(viewModel: contentViewModel)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                        Text("Glanceables")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                        if contentViewModel.webClips.isEmpty {
                            emptyStateView
                        } else {
                            urlGrid
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.85))
                .onAppear {
                    contentViewModel.loadURLs()
                }
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
        ForEach(contentViewModel.webClips) { item in
            WebGridSingleSnapshotView(id: item.id)
                .onDrag {
                    self.contentViewModel.draggedItem = item
                    return NSItemProvider(object: item.url.absoluteString as NSString)
                }
                .onDrop(of: [UTType.text], delegate: DropViewDelegate(item: item, viewModel: $contentViewModel.webClips, draggedItem: $contentViewModel.draggedItem))
                .contextMenu {
                    Button("Edit") {
                        contentViewModel.openEditForItem(item: item)
                    }
                    Button("Delete") {
                        contentViewModel.deleteItem(item: item)
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
