import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let imagePath: String
    
    init(imagePath: String) {
        self.imagePath = imagePath
    }
    
    func load() {
        let imagePath = imagePath
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            if let data = FileManager.default.contents(atPath: imagePath),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                print("Failed to load image from path: \(imagePath)")
            }
        }
    }
}
