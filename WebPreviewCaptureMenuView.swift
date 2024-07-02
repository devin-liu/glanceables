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
    @State private var scrollY: Double = 0
    
    @State private var startLocation: CGPoint? = nil
    @State private var endLocation: CGPoint? = nil
    @State private var dragging: Bool = false
    @State private var showPreview: Bool = false
    @State private var captureModeOn: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationView {
                HStack {
                    AddURLFormView(urlString: $urlString, validURL: $validURL, isURLValid: $isURLValid, isEditing: $isEditing)
                }
                .navigationBarTitle(isEditing ? "Edit URL" : "New URL")
                .navigationBarItems(
                    trailing: HStack {
                        CaptureModeToggleView(captureModeOn: $captureModeOn)
                        RedXButton(action: resetModalState)
                    }
                )
            }
            .frame(height: 300)
            .fixedSize(horizontal: false, vertical: true)
            
            
            HStack {
                if !isURLValid && !urlString.isEmpty {
                    Text("Invalid URL").foregroundColor(.red)
                }
                Button("Save") {
                    handleSaveURL()
                }.frame(width: 80, height: 40)
                
            }.frame(height: 80).fixedSize(horizontal: false, vertical: true)
            
            if let screenshot = screenshot, showPreview {
                Image(uiImage: screenshot)
                    .frame(width: 300, height: 300)
                    .padding()
            }
            
            if isURLValid && !showPreview {
                GeometryReader { geometry in
                    ZStack {
                        WebViewScreenshotCapture(url: $validURL, pageTitle: $pageTitle, clipRect: $currentClipRect, originalSize: $originalSize, screenshot: $screenshot, userInteracting: $userInteracting, scrollY: $scrollY)
                            .frame(maxHeight: .infinity)
                            .gesture(
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
                        if captureModeOn {
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
                        }
                        
                        
                    }
                }
            }
            Spacer()
        }
    }
    
    private func handleSaveURL() {
        if isURLValid {
            let validation = URLUtilities.validateURL(from: urlString)
            if validation.isValid && validation.url?.absoluteString != nil {
                if !urlString.isEmpty && validation.url?.absoluteString != nil {
                    var screenshotPath: String? = nil
                    if let screenshot = screenshot {
                        screenshotPath = ScreenshotUtils.saveScreenshotToLocalDirectory(screenshot: screenshot)
                    }
                    let newUrlItem = WebViewItem(id: UUID(), url: validURL!, clipRect: currentClipRect, originalSize: originalSize, screenshotPath: screenshotPath, scrollY: CGFloat(scrollY))
                    if isEditing, let index = selectedURLIndex {
                        urls[index] = newUrlItem
                    } else {
                        urls.append(newUrlItem)
                    }
                    resetModalState() // Reset modal only on successful save
                }
            }
        }
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
