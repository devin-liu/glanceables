import Foundation

struct CapturedElement: Codable {
    let relativeTop: Double
    let relativeLeft: Double
    let selector: String
}

struct HTMLElement: Codable {
    let outerHTML: String
    let innerText: String
    
}
