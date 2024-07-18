//
//  CapturedElements.swift
//  glanceables
//
//  Created by Devin Liu on 7/3/24.
//

import Foundation

struct CapturedElement: Codable {
    let relativeTop: Double
    let relativeLeft: Double
    let selector: String
}



struct HTMLElement: Codable {
    let innerHTML: String
    let outerHTML: String
    let tagName: String
    let attributes: [String: String]
}
