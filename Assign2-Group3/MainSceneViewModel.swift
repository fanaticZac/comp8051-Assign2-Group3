//
//  MainSceneViewModel.swift
//  Assign2-Group3
//
//  Created by user on 2/25/24.
//
import Foundation
import SwiftUI
import SceneKit

class MainSceneViewModel: ObservableObject {
    @Published var scene = MainScene()
    
    func updateCameraPosition(cameraXOffset: Float, cameraYOffset: Float) {
        scene.updateCameraPosition(cameraXOffset: cameraXOffset, cameraZOffset: cameraYOffset)
    }
    
    func resetCameraPosition() {
        scene.resetCameraPosition()
    }
    
    func toggleFog(distance: CGFloat, density: CGFloat) {
        scene.toggleFog(distance: distance, density: density)
    }
    
    func toggleFlashlight() {
        scene.toggleFlashlight()
    }
    
    func toggleConsole() {
        scene.toggleConsole()
    }
}
