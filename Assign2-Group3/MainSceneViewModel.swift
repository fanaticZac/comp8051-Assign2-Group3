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
    
    func toggleSpiderAnimation() {
        scene.toggleSpiderAnimation()
    }
    
    func manuallyUpdateSpiderPosition(rotateAngle: Float, movement: Float) {
        scene.manuallyUpdateSpiderPosition(rotateAngle: rotateAngle, movement: movement)
    }
    
    func manualZoom(scale: Float) {
        scene.manualZoom(scale: scale)
    }
}
