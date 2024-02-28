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
            ZStack {
                SceneKitView(scene: mainSceneViewModel.scene)
                    .gesture(DragGesture().onChanged { value in
                        let sensitivity: Float = 0.0001 // Adjust the sensitivity of the drag
                        let cameraXOffset = Float(value.translation.width) * sensitivity
                        let cameraZOffset = -Float(value.translation.height) * sensitivity
                        
                        mainSceneViewModel.scene.updateCameraPosition(cameraXOffset: cameraXOffset, cameraZOffset: cameraZOffset)
                    })
                    .onTapGesture(count:2) {
                        mainSceneViewModel.scene.resetCameraPosition()
                    }
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Button("Toggle Fog", action: {mainSceneViewModel.scene.toggleFog()})
                    Button("Toggle Daylight", action: {mainSceneViewModel.scene.toggleDaylight()})
                    Button("Toggle Flashlight", action: {mainSceneViewModel.scene.toggleFlashlight()})
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
        
    @State private var isShowing = false

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("Assign2\nThe Maze-ening")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .opacity(isShowing ? 1 : 0)
                    .animation(.easeInOut(duration: 3))
                
                Button("Start Game") {
                    print("Start Game button pressed")
                    startAction()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                .padding()
                .opacity(isShowing ? 1 : 0)
                .animation(.easeInOut(duration: 5))
                               
                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                self.isShowing = true
            }
        }
    }
}

