import SwiftUI

@Observable class WebClipSelectorViewModel {
    var currentClipRect: CGRect?
    var userInteracting: Bool = false
    var scrollY: Double = 0
    var capturedElements: [CapturedElement]?
    var startLocation: CGPoint? = nil
    var endLocation: CGPoint? = nil
    var dragging: Bool = false
    var dragEnded: Bool = false
    var showPreview: Bool = false
    var captureModeOn: Bool = true
    
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
