import UIKit

struct ScreenshotUtils {
    static func saveScreenshotToLocalDirectory(screenshot: UIImage) -> String? {
        guard let data = screenshot.jpegData(compressionQuality: 1.0) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("Error saving screenshot: \(error)")
            return nil
        }
    }
    
    static func saveScreenshotToFile(using webClip: WebClip, from screenshot: UIImage) -> String? {
        guard let data = screenshot.jpegData(compressionQuality: 1.0) else { return nil }
        let url = URL(fileURLWithPath: webClip.screenshotPath.unsafelyUnwrapped)

        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("Error refreshing screenshot: \(error)")
            return nil
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
