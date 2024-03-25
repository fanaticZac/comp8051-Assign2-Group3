
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
    let mainSceneViewModel: MainSceneViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = scene

        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator,
                                                                 action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTouchesRequired = 2
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(mainSceneViewModel: mainSceneViewModel)
    }
    
    class Coordinator: NSObject {
        let mainSceneViewModel: MainSceneViewModel
        
        init(mainSceneViewModel: MainSceneViewModel) {
            self.mainSceneViewModel = mainSceneViewModel
        }
        
        @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .recognized {
                mainSceneViewModel.scene.toggleConsole()
            }
        }
    }
}
