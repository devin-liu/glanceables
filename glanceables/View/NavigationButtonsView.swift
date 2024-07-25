import SwiftUI

struct NavigationButtonsView: View {
    var body: some View {
        HStack {
            // Back Button
            Button(action: {
                // Action for the back button
                print("Back button tapped")
            }) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())

            // Forward Button
            Button(action: {
                // Action for the forward button
                print("Forward button tapped")
            }) {
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct NavigationButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationButtonsView()
    }
}
