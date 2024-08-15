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
    
    static func saveScreenshotToFile(screenshotPath: String, from screenshot: UIImage) -> String? {
        guard let data = screenshot.jpegData(compressionQuality: 1.0) else { return nil }
        let url = URL(fileURLWithPath: screenshotPath)
        
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
    
    static func loadImage(from path: String?) -> UIImage? {
        guard let path = path else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
