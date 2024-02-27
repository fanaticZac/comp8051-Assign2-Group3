//
//  ContentView.swift
//  Assign2-Group3
//
//  Created by user on 2/23/24.
//
import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var mainSceneViewModel = MainSceneViewModel()
    @State private var isGameStarted = false // State to track if the game has started
    
    var body: some View {
            if isGameStarted {
                ZStack{
                    SceneKitView(scene: mainSceneViewModel.scene)
                        .gesture(DragGesture().onChanged { value in
                            let sensitivity: Float = 0.01 // Adjust the sensitivity of the drag
                            let cameraXOffset = Float(value.translation.width) * sensitivity
                            let cameraZOffset = -Float(value.translation.height) * sensitivity
                            
                            mainSceneViewModel.scene.updateCameraPosition(cameraXOffset: cameraXOffset, cameraZOffset: cameraZOffset)
                            
                        })
                        .edgesIgnoringSafeArea(.all)
                        
                    VStack{
                        Button("Toggle Daylight", action: {mainSceneViewModel.scene.toggleDaylight()})
                        Spacer()
                    }
                }
            } else {
                StartScreenView {
                    isGameStarted = true
                }
                .edgesIgnoringSafeArea(.all)
            }

        }
}

struct StartScreenView: View {
    var startAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Assign2 - The Maze-ening")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(5)
                .padding()
            
            Button("Start Game") {
                print("Start Game button pressed")
                startAction()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
        }
    }
}
