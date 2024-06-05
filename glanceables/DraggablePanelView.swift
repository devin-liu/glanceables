import SwiftUI

struct DraggablePanel: View {
    @GestureState private var dragState = CGSize.zero
    @State private var position = CGSize.zero

    var body: some View {
        VStack {
            Text("Draggable Panel")
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .foregroundColor(.white)
                .offset(x: position.width + dragState.width, y: position.height + dragState.height)
                .gesture(
                    DragGesture()
                        .updating($dragState) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            self.position.height += value.translation.height
                            self.position.width += value.translation.width
                        }
                )
        }
    }
}
