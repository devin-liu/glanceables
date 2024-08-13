import SwiftUI

struct CreateButtonView: View {
    var webClipManager: WebClipManagerViewModel
    
    var body: some View {
        NavigationLink(destination: WebClipCreatorView(webClipManager: webClipManager)) {
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
                    .font(.system(.footnote, design: .rounded)) // Use dynamic type with style
                    .fontWeight(.medium)
                    .foregroundColor(Color.black)
            }
        }
    }
}

struct CreateButtonView_Previews: PreviewProvider {
    static var previews: some View {
        let webClipManager = WebClipManagerViewModel()
        CreateButtonView(webClipManager: webClipManager)
            .previewLayout(.sizeThatFits) // Adjust this to match the context you want to preview in
            .padding()
    }
}
