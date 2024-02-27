//
//  MainScene.swift
//  Assign2-Group3
//
//  Created by user on 2/25/24.
//
import SceneKit

class MainScene: SCNScene {
    var cameraNode = SCNNode()
    var mazeNode = SCNNode()
    var cameraXOffset: Float = 5
    var cameraYOffset: Float = 20
    var cameraZOffset: Float = 5
    let mazeWrapper: MazeWrapper = MazeWrapper(rows: 10, columns: 10)
    var touched = false
    var fog = false
    var flashlightOn = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Initializer
    override init() {
        super.init()
        
        background.contents = UIColor.black
        
        setupCamera()
        addMazeToScene()
        setupFog()
//        setupFlashlight()
    }
    
    // CAMERA // ////////////
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(cameraXOffset, cameraYOffset, cameraZOffset)
     
        // temp - just to look down
        cameraNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)

        rootNode.addChildNode(cameraNode)
    }
    
    func updateCameraPosition(cameraXOffset: Float, cameraZOffset: Float) {
        // Moves camera to player on first touch
        if (!touched) {
            cameraNode.position = SCNVector3(0,0,-1)
            cameraNode.eulerAngles = SCNVector3(0,-Float.pi,0)
            touched = true
        }
        if (cameraZOffset * 1000 < 2 && cameraZOffset * 1000 > -2 && cameraXOffset != 0) {
            if (cameraNode.eulerAngles.y < Float.pi || cameraNode.eulerAngles.y > -3*Float.pi) {
                cameraNode.eulerAngles = SCNVector3(0, cameraNode.eulerAngles.y + cameraXOffset, 0)
            } else {
                cameraNode.eulerAngles = SCNVector3(0,-Float.pi,0)
            }
        }
        else {
            cameraNode.position = SCNVector3(cameraNode.position.x + cameraXOffset, 0, cameraNode.position.z + cameraZOffset)
        }
    }
    
    func resetCameraPosition() {
        cameraNode.position = SCNVector3(0,0,0)
        cameraNode.eulerAngles = SCNVector3(0,-Float.pi/2,0)
    }
  
    // MAZE // ////////////
    func addMazeToScene() {
        mazeWrapper.createMaze()
            
        let cellSize: CGFloat = 1.0
        
        let colors: [CompassDirection: UIColor] = [
            .dNORTH: .red,
            .dEAST: .green,
            .dSOUTH: .blue,
            .dWEST: .yellow
        ]
            
        for row in 0..<Int32(mazeWrapper.rows) {
            for col in 0..<Int32(mazeWrapper.columns) {
                for direction in [CompassDirection.dNORTH, .dEAST, .dSOUTH, .dWEST] {
                    let cell = mazeWrapper.isWallPresent(atRow: Int32(row), column: Int32(col), direction: Int32(direction.rawValue))
                    
                    let position = SCNVector3(x: Float(col) * Float(cellSize), y: 0, z: Float(row) * Float(cellSize))
                    
                    // Create geometry for each wall based on cell data
                    if cell {
                        var width: CGFloat = cellSize
                        var height: CGFloat = cellSize
                        var length: CGFloat = cellSize
                        var positionAdjustment = SCNVector3Zero // Adjustment to align walls properly
                        
                        // Adjust dimensions and position for different directions
                        switch direction {
                        case .dNORTH:
                            width = cellSize
                            length = 0.1
                            positionAdjustment = SCNVector3(0, 0, -cellSize/2)
                        case .dEAST:
                            width = 0.1
                            length = cellSize
                            positionAdjustment = SCNVector3(cellSize/2, 0, 0)
                        case .dSOUTH:
                            width = cellSize
                            length = 0.1
                            positionAdjustment = SCNVector3(0, 0, cellSize/2)
                        case .dWEST:
                            width = 0.1
                            length = cellSize
                            positionAdjustment = SCNVector3(-cellSize/2, 0, 0)
                        }
                        
                        let color = colors[direction] ?? .white
                        
                        let material = SCNMaterial()
                        material.diffuse.contents = color
                        
                        let wallGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
                        wallGeometry.materials = [material] // Apply material to geometry
                        
                        let wallNode = SCNNode(geometry: wallGeometry)
                        wallNode.position = SCNVector3Make(position.x + positionAdjustment.x, position.y + positionAdjustment.y, position.z + positionAdjustment.z)
                        mazeNode.addChildNode(wallNode)

                    }
                }
                
            }
        }
            
            rootNode.addChildNode(mazeNode)
        }

    func setupFog() {
        fogColor = UIColor.white
        fogStartDistance = 0.0
        fogEndDistance = 0.0
        fogDensityExponent = 3.0
    }
    
    func toggleFog() {
        if (!fog) {
            fogEndDistance = 2.0
            fog = true
        } else {
            fogEndDistance = 0.0
            fog = false
        }
    }
    
//    func setupFlashlight() {
//        let lightNode = SCNNode()
//        lightNode.name = "Flashlight"
//        lightNode.light = SCNLight()
//        lightNode.light!.type = SCNLight.LightType.spot
//        lightNode.light!.castsShadow = true
//        lightNode.light!.color = UIColor.green
//        lightNode.light!.intensity = 0
//        lightNode.position = SCNVector3(0, 0, 0)
//        lightNode.rotation = SCNVector4(1, 0, 0, -Double.pi/3)
//        lightNode.light!.spotInnerAngle = 0
//        lightNode.light!.spotOuterAngle = 20.0
//        lightNode.light!.shadowColor = UIColor.black
//        lightNode.light!.zFar = 500
//        lightNode.light!.zNear = 50
//        cameraNode.addChildNode(lightNode)
//    }
//    
//    func toggleFlashlight() {
//        let flashlight = cameraNode.childNode(withName: "Flashlight", recursively: true)
//        if (flashlightOn) {
//            flashlight?.light!.intensity = 0;
//            flashlightOn = false
//        }
//        else {
//            flashlight?.light!.intensity = 5000;
//            flashlightOn = true
//        }
//    }
   
}
