import SwiftUI

struct URLValidator {
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string, let url = URL(string: urlString) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }

    func isValidURLFormat(_ string: String) -> Bool {
        let regex = "^(https?://)?([\\w\\d-]+\\.)+[\\w\\d-]+/?([\\w\\d-._\\?,'+/&%$#=~]*)*[^.]$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: string)
    }

    func completeURL(_ string: String) -> URL? {
        let urlString = string.hasPrefix("http://") || string.hasPrefix("https://") ? string : "https://" + string
        return URL(string: urlString)
    }
}
