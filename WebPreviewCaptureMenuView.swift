import SwiftUI
import Combine

struct WebPreviewCaptureMenuView: View {
    @ObservedObject var viewModel: WebClipEditorViewModel
    
    @State private var debounceWorkItem: DispatchWorkItem?
    @State private var pageTitle: String = "Loading..."
    @State private var currentClipRect: CGRect?
    @State private var screenshot: UIImage?
    @State private var userInteracting: Bool = false
    @State private var scrollY: Double = 0
    @State private var capturedElements: [CapturedElement]?
    
    @State private var startLocation: CGPoint? = nil
    @State private var endLocation: CGPoint? = nil
    @State private var dragging: Bool = false
    @State private var showPreview: Bool = false
    @State private var captureModeOn: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationView {
                HStack {
                    AddURLFormView(viewModel: viewModel)
                }
                .navigationBarTitle(viewModel.isEditing ? "Edit URL" : "New URL")
                .navigationBarItems(
                    trailing: HStack {
                        CaptureModeToggleView(captureModeOn: $captureModeOn)
                        RedXButton(action: viewModel.resetModalState)
                    }
                )
            }
            .frame(height: 300)
            .fixedSize(horizontal: false, vertical: true)
            
            
            HStack {
                if !viewModel.isURLValid && !viewModel.urlString.isEmpty {
                    Text("Invalid URL").foregroundColor(.red)
                }
                Button("Save") {
                    viewModel.saveURL(with: screenshot, currentClipRect: currentClipRect, pageTitle: pageTitle)
                }.frame(width: 80, height: 40)
                
            }.frame(height: 80).fixedSize(horizontal: false, vertical: true)
            
            if let screenshot = screenshot, showPreview {
                Image(uiImage: screenshot)
                    .frame(width: 300, height: 300)
                    .padding()
            }
            
            if viewModel.isURLValid && !showPreview {
                GeometryReader { geometry in
                    ZStack {
                        WebViewScreenshotCapture(viewModel: viewModel, pageTitle: $pageTitle, clipRect: $currentClipRect, screenshot: $screenshot, userInteracting: $userInteracting, scrollY: $scrollY, capturedElements: $capturedElements)
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
                                        //                                        showPreview = true
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
