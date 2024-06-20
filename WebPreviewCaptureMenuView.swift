import SwiftUI
import Combine

struct WebPreviewCaptureMenuView: View {
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
                                .frame(width: 300, height: 300)
                                .padding()
                        }
                    }
                }
                if isURLValid {
                    GeometryReader { geometry in
                        ZStack {
                            WebViewScreenshotCapture(url: $validURL, pageTitle: $pageTitle, clipRect: $currentClipRect, originalSize: $originalSize, screenshot: $screenshot, userInteracting: $userInteracting)
                                .frame(maxHeight: .infinity)
                            
                            if let clipRect = currentClipRect {
                                if dragging {
                                    Rectangle()
                                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                                        .path(in: clipRect)
                                        .background(Color.black.opacity(0.1))
                                }
                                Rectangle()
                                    .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                                    .path(in: clipRect)
                            }
                            
                            
                        } .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    startLocation = startLocation ?? value.location
                                    endLocation = value.location
                                    dragging = true
                                    updateClipRect(endLocation: value.location, bounds: geometry.size)
                                }
                                .onEnded { _ in
                                    dragging = false
                                    showPreview = true
                                }
                        )
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
            if !urlString.isEmpty && validURL?.absoluteString != nil {
                var screenshotPath: String? = nil
                if let screenshot = screenshot {
                    screenshotPath = ScreenshotUtils.saveScreenshotToLocalDirectory(screenshot: screenshot)
                    
                }
                let newUrlItem = WebViewItem(id: UUID(), url: validURL!, clipRect: currentClipRect, originalSize: originalSize, screenshotPath: screenshotPath)
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
        let validation = URLUtilities.validateURL(from: urlString)
        isURLValid = validation.isValid
        validURL = validation.url
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
    
    private func updateClipRect(endLocation: CGPoint, bounds: CGSize) {
        let width = 300.0
        let height = 300.0
        
        let centerX = endLocation.x
        let centerY = endLocation.y
        
        let minX = max(0, min(centerX - width / 2, bounds.width - width))
        let minY = max(0, min(centerY - height / 2, bounds.height - height))
        
        currentClipRect = CGRect(x: minX, y: minY, width: width, height: height)
    }
}
