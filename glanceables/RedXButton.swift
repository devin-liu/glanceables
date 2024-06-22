import SwiftUI

struct RedXButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40) // Adjust size as needed
                Text("X")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .shadow(radius: 3) // Optional: adds shadow for 3D effect
    }
}
