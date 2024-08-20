//
//  WebClipRefresherGrid.swift
//  glanceables
//
//  Created by Devin Liu on 8/18/24.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct WebClipRefresherGrid: View {
    @Environment(WebClipManagerViewModel.self) private var webClipManager
    
    var body: some View {
        List(webClipManager.webClips) { item in
            WebViewSnapshotRefresher(webClipId: item.id)
                .edgesIgnoringSafeArea(.all)
                .opacity(0)  // Make the View invisible
        }
    }
}
