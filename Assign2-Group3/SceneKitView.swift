
//
//  SceneKitView.swift
//  Assign2-Group3
//
//  Created by user on 2/25/24.
//

import Foundation
import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene
    
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = scene
                
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // No updates needed
    }
}
