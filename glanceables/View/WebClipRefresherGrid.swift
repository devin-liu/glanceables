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
            ForEach(webClipManager.webClips) { item in
                WebViewSnapshotRefresher(webClipId: item.id)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0)  // Make the ScrollView invisible
            }
        }
    }
}
