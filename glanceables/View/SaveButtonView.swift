import SwiftUI

struct SaveButtonView: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("SAVE")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 100, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}

struct SaveButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SaveButtonView {            
            print("Save button tapped")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
