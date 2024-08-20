import SwiftUI

@Observable class WebClipSelectorViewModel {
    private(set) var currentClipRect: CGRect?
    private(set) var userInteracting: Bool = false
    private(set) var scrollY: Double = 0
    private(set) var capturedElements: [CapturedElement]?
    private(set) var startLocation: CGPoint? = nil
    private(set) var endLocation: CGPoint? = nil
    private(set) var dragging: Bool = false
    private(set) var dragEnded: Bool = false
    private(set) var showPreview: Bool = false
    
    private var _captureModeOn: Bool = true
    var captureModeOn: Bool {
        get { _captureModeOn }
        set {
            _captureModeOn = newValue
            if !newValue {
                // Reset related properties when capture mode is turned off
                currentClipRect = nil
                capturedElements = nil
            }
        }
    }
    
    func setUserInteracting(_ value: Bool) {
        userInteracting = value
    }
    
    func setScrollY(_ value: Double) {
        scrollY = max(0, value) // Ensure scrollY is never negative
    }
    
    func setStartLocation(_ point: CGPoint?) {
        startLocation = point
        if point != nil {
            dragging = true
            dragEnded = false
        }
    }
    
    func setEndLocation(_ point: CGPoint?) {
        endLocation = point
        if point == nil {
            dragging = false
            dragEnded = true
        }
    }
    
    func setShowPreview(_ value: Bool) {
        showPreview = value
    }
    
    func setCapturedElements(_ elements: [CapturedElement]?) {
        capturedElements = elements
    }
    
    func setDragging(_ value: Bool){
        dragging = value
    }
    
    func setDragEnded(_ value: Bool){
        dragEnded = value
    }
    
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
