import Foundation
import UIKit

struct URLUtilities {
    static func validateURL(from urlString: String) -> (isValid: Bool, url: URL?) {
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            let modifiedURLString = "https://" + urlString
            return checkURL(modifiedURLString)
        }
        return checkURL(urlString)
    }
    
    private static func checkURL(_ urlString: String) -> (isValid: Bool, url: URL?) {
        if let url = URL(string: urlString), canOpenURL(url) && isValidURLFormat(urlString) {
            return (true, url)
        } else {
            return (false, nil)
        }
    }
    
    static func canOpenURL(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
    
    static func isValidURLFormat(_ urlString: String) -> Bool {
        let regex = "^(https?://)?([\\w\\d-]+\\.)+[\\w\\d-]+/?([\\w\\d-._\\?,'+/&%$#=~]*)*[^.]$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: urlString)
    }
    
    static func simplifyPageTitle(_ title: String) -> String {
        // Define allowed characters as alphanumerics and whitespaces
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        
        // Find the range of the first character that is not allowed
        if let range = title.rangeOfCharacter(from: allowedCharacters.inverted) {
            let firstPart = title[..<range.lowerBound]
            return firstPart.trimmingCharacters(in: .whitespaces)
        }
        
        // If no invalid character is found, trim and return the whole title
        return title.trimmingCharacters(in: .whitespaces)
    }
    
    
}
