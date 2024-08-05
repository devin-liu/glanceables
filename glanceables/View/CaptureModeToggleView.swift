import SwiftUI

struct CaptureModeToggleView: View {
    @ObservedObject private var viewModel = WebClipSelectorViewModel.shared
    
    
    var body: some View {
        HStack(spacing: 10) {  // Reduced spacing between elements
            VStack {  // Use VStack for vertical stacking of text
                Text("CAPTURE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Text("MODE")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Toggle("", isOn: $viewModel.captureModeOn)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .frame(width: 51, height: 31)  // Specific sizing for the toggle
        }
        .padding(.horizontal, 10)  // Horizontal padding
        .padding(.vertical, 5)  // Vertical padding
        .cornerRadius(10)  // Optional: Rounded corners for the background
    }
}

// SwiftUI Preview
struct CaptureModeToggleView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureModeToggleView()
            .previewLayout(.sizeThatFits)  // Uses minimal size that fits the content
    }
}
