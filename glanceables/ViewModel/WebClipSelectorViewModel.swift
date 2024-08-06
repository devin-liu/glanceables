import SwiftUI
import Combine

class WebClipSelectorViewModel: ObservableObject {
    static let shared = WebClipSelectorViewModel()  // Singleton instance
    @Published var currentClipRect: CGRect?
    @Published var userInteracting: Bool = false
    @Published var scrollY: Double = 0
    @Published var capturedElements: [CapturedElement]?
    @Published var startLocation: CGPoint? = nil
    @Published var endLocation: CGPoint? = nil
    @Published var dragging: Bool = false
    @Published var dragEnded: Bool = false
    @Published var showPreview: Bool = false
    @Published var captureModeOn: Bool = true
    
    func updateClipRect(endLocation: CGPoint, bounds: CGSize) {
        let width = 300.0
        let height = 300.0
        
        let centerX = endLocation.x
        let centerY = endLocation.y
        
        let minX = max(0, min(centerX - width / 2, bounds.width - width))
        let minY = max(0, min(centerY - height / 2, bounds.height - height))
        
        currentClipRect = CGRect(x: minX, y: minY, width: width, height: height)
    }
    
    
}
