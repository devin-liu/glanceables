import Foundation

// Struct to decode the JSON response
struct Response: Codable {
    let model: String
    let response: String
}
