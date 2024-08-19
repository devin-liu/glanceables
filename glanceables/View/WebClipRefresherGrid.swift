//
//  WebClipRefresherGrid.swift
//  glanceables
//
//  Created by Devin Liu on 8/18/24.
//

import Foundation
import SwiftUI

struct WebClipRefresherGrid: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    
    let columns = [GridItem(.adaptive(minimum: 300))]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(webClipManager.getClips(), id: \.self) { item in
                WebViewSnapshotRefresher(webClipId: item.id)
                    .frame(width: item.originalSize?.width, height: 600)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0)  // Make the ScrollView invisible
                    .frame(width: 0, height: 0)  // Make the ScrollView occupy no space
            }
        }
    }
}
