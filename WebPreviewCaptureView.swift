import SwiftUI
import Combine

struct WebPreviewCaptureView: View {
    @Binding var showingURLModal: Bool
    @Binding var urlString: String
    @Binding var isURLValid: Bool
    @Binding var urls: [WebViewItem]
    @Binding var selectedURLIndex: Int?
    @Binding var isEditing: Bool
    
    @State private var debounceWorkItem: DispatchWorkItem?
    @State private var validURL: URL?
    @State private var pageTitle: String = "Loading..."
    @State private var currentClipRect: CGRect?
    @State private var originalSize: CGSize?
    @State private var screenshot: UIImage?
    @State private var userInteracting: Bool = false

    @State private var startLocation: CGPoint? = nil
    @State private var endLocation: CGPoint? = nil
    @State private var dragging: Bool = false
    @State private var showPreview: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text(isEditing ? "Edit URL" : "Add a new URL").padding(.top, 20)) {
                        TextField("Enter URL here", text: $urlString)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .padding(.vertical, 20)
                            .onChange(of: urlString, perform: { newValue in
                                debounceValidation()
                            })
                    }
                    Section {
                        if let clipRect = currentClipRect {
                            Text("Clipping Rectangle: \(clipRect.debugDescription)").padding()
                            Button("Clear Clipping") {
                                currentClipRect = nil
                                showPreview = false
                            }
                        }
                        if !isURLValid && !urlString.isEmpty {
                            Text("Invalid URL").foregroundColor(.red)
                        }
                        Button("Save") {
                            handleSaveURL()
                        }
                        .padding(.vertical, 20)
                        if let screenshot = screenshot, showPreview {
                            Image(uiImage: screenshot)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .padding()
                        }
                    }
                }
                if isURLValid, let url = validURL {
                    ZStack {
                        WebViewScreenshotCapture(url: .constant(url), pageTitle: $pageTitle, clipRect: $currentClipRect, originalSize: $originalSize, screenshot: $screenshot, userInteracting: $userInteracting)
                            .frame(maxHeight: .infinity)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if startLocation == nil {
                                            startLocation = value.location
                                        }
                                        endLocation = value.location
                                        dragging = true
                                        updateClipRect()
                                    }
                                    .onEnded { _ in
                                        dragging = false
                                        showPreview = true
                                    }
                            )
                        if let clipRect = currentClipRect, dragging {
                            Rectangle()
                                .path(in: clipRect)
                                .stroke(Color.blue, lineWidth: 2)
                                .background(Color.blue.opacity(0.2))
                        }
                    }
                }
            }
            .navigationBarTitle(isEditing ? "Edit URL" : "New URL", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                resetModalState()
            })
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func handleSaveURL() {
        validateURL()
        if isURLValid {
            if !urlString.isEmpty {
                var screenshotPath: String? = nil
                if let screenshot = screenshot {
                    screenshotPath = saveScreenshotToLocalDirectory(screenshot: screenshot)
                }
                let newUrlItem = WebViewItem(id: UUID(), url: URL(string: urlString)!, clipRect: currentClipRect, originalSize: originalSize, screenshotPath: screenshotPath)
                if isEditing, let index = selectedURLIndex {
                    urls[index] = newUrlItem
                } else {
                    urls.append(newUrlItem)
                }
                resetModalState() // Reset modal only on successful save
            }
        }
    }

    private func debounceValidation() {
        debounceWorkItem?.cancel()
        debounceWorkItem = DispatchWorkItem {
            validateURL()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: debounceWorkItem!)
    }

    private func validateURL() {
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        if let url = URL(string: urlString), canOpenURL(urlString) && isValidURLFormat(urlString) {
            isURLValid = true
            validURL = url
        } else {
            isURLValid = false
            validURL = nil
        }
    }
   
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

    private func resetModalState() {
        showingURLModal = false
        urlString = ""
        isEditing = false
        selectedURLIndex = nil
        isURLValid = true
        validURL = nil
        currentClipRect = nil
        originalSize = nil
        screenshot = nil
        startLocation = nil
        endLocation = nil
        showPreview = false
    }

    private func saveScreenshotToLocalDirectory(screenshot: UIImage) -> String? {
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

    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func updateClipRect() {
        guard let start = startLocation, let end = endLocation else { return }
        let minX = min(start.x, end.x)
        let minY = min(start.y, end.y)
        let maxX = max(start.x, end.x)
        let maxY = max(start.y, end.y)
        currentClipRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
