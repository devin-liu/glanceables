import SwiftUI

struct CreateButtonView: View {
    var body: some View {
        
            VStack { // Adjust spacing between the icon box and the text
                ZStack {
                    Rectangle()
                        .frame(width: 60, height: 60) // Define the size of the square
                        .foregroundColor(Color.white) // Set the color of the square
                        .cornerRadius(10) // Rounded corners for the square
                    
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 24) // Adjust the size of the plus icon
                        .foregroundColor(Color.gray) // Set the icon color to white
                }
                
                
            }
            .frame(width: 144, height: 170) // Define the overall frame size of the button
            .background(Color.black.opacity(0.3)) // Background color of the whole component
            .cornerRadius(24) // Rounded corners for the entire component
            .shadow(radius: 6) // Optional: add shadow for a slight depth effect
            
            Text("Create Your First Glanceable")
                .font(.system(size: 12)) // Smaller font size for the text
                .fontWeight(.medium) // Medium font weight
                .foregroundColor(Color.black) // Text color set to gray
        }
    
}

struct CreateButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            CreateButtonView()
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
