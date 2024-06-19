//
//  GIFView.swift
//  CONpanion
//
//  Created by jake mccarthy on 30/05/2024.
//

import SwiftUI
import WebKit

// View for displaying GIFs:
struct GIFView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
