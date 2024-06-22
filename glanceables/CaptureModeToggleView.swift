import SwiftUI

struct CaptureModeToggleView: View {
    @Binding var captureModeOn: Bool

    var body: some View {
        HStack {
            Text("CAPTURE MODE")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Toggle("", isOn: $captureModeOn)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding()
//        .background(Color.black) // Assuming the toggle bar has a black background
        .cornerRadius(10) // Optional: if you want rounded corners
    }
}
