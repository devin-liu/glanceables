import SwiftUI

struct CreateButtonView: View {
    @Binding var isShowingModal: Bool // Add a binding property

    var body: some View {
        Button(action: {
            isShowingModal.toggle() // Action to show modal
        }) {
            VStack {
                ZStack {
                    Rectangle()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                    
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 24)
                        .foregroundColor(Color.gray)
                }
                .frame(width: 144, height: 170)
                .background(Color.black.opacity(0.3))
                .cornerRadius(24)
                .shadow(radius: 6)

                Text("Create Your First Glanceable")
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(Color.black)
            }
        }
    }
}


struct CreateButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Use a state wrapper in your preview environment
        StatefulPreviewWrapper(false) { isShowingModal in
            VStack {
                CreateButtonView(isShowingModal: isShowingModal)
                    .previewLayout(.sizeThatFits)
                    .padding()
            }
        }
    }
}

/// Helper struct to provide a mutable state for previews
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content
    
    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
