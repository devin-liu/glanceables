import UIKit
import SwiftUI

class HeaderViewController: UIViewController {
    var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize and set up the title label
        titleLabel = UILabel()
        titleLabel.text = "Glanceables"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 60)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        // Set constraints for left alignment
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32)
        ])
        
        view.backgroundColor = .clear
    }
}

struct HeaderView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HeaderViewController {
        HeaderViewController()
    }
    
    func updateUIViewController(_ uiViewController: HeaderViewController, context: Context) {
        // Update the view controller if needed
    }
}



#Preview {
    HeaderView()
}
