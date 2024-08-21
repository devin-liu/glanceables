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
            ForEach(webClipManager.webClips, id: \.self) { item in            
                let updaterViewModel = WebClipUpdaterViewModel(webClip: item)
                WebViewSnapshotRefresher(webClipId: item.id, updaterViewModel: updaterViewModel)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0)  // Make the ScrollView invisible
            }
        }
    }
}
