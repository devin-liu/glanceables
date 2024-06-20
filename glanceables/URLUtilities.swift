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
}
