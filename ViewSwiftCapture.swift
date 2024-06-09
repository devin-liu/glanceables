import Foundation
import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeCaptureModifier: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { preferences in
                self.size = preferences
            }
    }
}

extension View {
    func captureSize(in size: Binding<CGSize>) -> some View {
        self.modifier(SizeCaptureModifier(size: size))
    }
}
