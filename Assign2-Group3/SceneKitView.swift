
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
    
    let view = SCNView(frame: .zero)
    
    func makeUIView(context: Context) -> SCNView {
        view.scene = scene

        let singleTapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSingleTap(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(singleTapGestureRecognizer)
        
        let dragGestureRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDrag(_:)))
        view.addGestureRecognizer(dragGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator,
                                                                 action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTouchesRequired = 2
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        
        let tripleTapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTripleTap(_:)))
        tripleTapGestureRecognizer.numberOfTapsRequired = 2
        tripleTapGestureRecognizer.numberOfTouchesRequired = 3
        view.addGestureRecognizer(tripleTapGestureRecognizer)
        
        return view
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(mainSceneViewModel: mainSceneViewModel, view)
    }
    
    class Coordinator: NSObject {
        let view: SCNView
        let mainSceneViewModel: MainSceneViewModel
        
        init(mainSceneViewModel: MainSceneViewModel, _ view: SCNView) {
            self.mainSceneViewModel = mainSceneViewModel
            self.view = view
        }
        
        @objc func handleSingleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .recognized {
                mainSceneViewModel.scene.resetCameraPosition()
            }
        }
        
        @objc func handleDrag(_ gestureRecognizer: UIPanGestureRecognizer) {
            if (gestureRecognizer.state != .cancelled) {
                let sensitivity: Float = 0.0001 // Adjust the sensitivity of the drag
                let cameraXOffset = Float(gestureRecognizer.translation(in: view).x) * sensitivity
                let cameraZOffset = -Float(gestureRecognizer.translation(in: view).y) * sensitivity
                let p = gestureRecognizer.location(in: view)
                let hitResults = view.hitTest(p, options: [:])
                if (hitResults.count > 0) {
                    let results = hitResults[0]
                    if (results.node.name == "Spider") {
                        mainSceneViewModel.manuallyUpdateSpiderPosition(rotateAngle: cameraXOffset, movement: cameraZOffset)
                    } else {
                        mainSceneViewModel.updateCameraPosition(cameraXOffset: cameraXOffset, cameraYOffset: cameraZOffset)
                    }
                } else {
                    mainSceneViewModel.updateCameraPosition(cameraXOffset: cameraXOffset, cameraYOffset: cameraZOffset)
                }
            }
        }
        
        @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
            if (gestureRecognizer.state == .changed) {
                let p = gestureRecognizer.location(in: view)
                let hitResults = view.hitTest(p, options: [:])
                if (hitResults.count > 0) {
                    let results = hitResults[0]
                    if (results.node.name == "Spider") {
                        mainSceneViewModel.manualZoom(scale: Float(gestureRecognizer.scale))
                    }
                }
            }
        }
        
        @objc func handleTripleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .recognized {
                mainSceneViewModel.scene.toggleConsole()
            }
        }
        
        @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .recognized {
                let p = gestureRecognizer.location(in: view)
                let hitResults = view.hitTest(p, options: [:])
                if (hitResults.count > 0) {
                    let results = hitResults[0]
                    if (results.node.name == "Spider") {
                        mainSceneViewModel.scene.toggleSpiderAnimation()
                    }
                }
            }
        }
    }
}
