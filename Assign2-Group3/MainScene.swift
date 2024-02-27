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
    var rotAngle = 0.0
    let mazeWrapper: MazeWrapper = MazeWrapper(rows: 10, columns: 10)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Initializer
    override init() {
        super.init()
        
        background.contents = UIColor.black
        
        setupCamera()
        addMazeToScene()
        addRotatingTexturedCube()
        
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
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
    
    func addRotatingTexturedCube(){
        let theCube = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
        theCube.name = "The Cube"
        theCube.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "crate.jpg")
        theCube.position = SCNVector3(0,0,0)
        rootNode.addChildNode(theCube)
    }
    
    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    @MainActor
    func reanimate() {
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true)
//        if (isRotating) {
            rotAngle += 0.0005
            if rotAngle > Double.pi {
                rotAngle -= Double.pi*2
            }
//        }
        theCube?.eulerAngles = SCNVector3(rotAngle, rotAngle, rotAngle)
        Task { try! await Task.sleep(nanoseconds: 10000)
            reanimate()
        }
    }
    
    func updateCameraPosition(cameraXOffset: Float, cameraZOffset: Float) {
        cameraNode.position = SCNVector3(cameraXOffset, cameraZOffset, cameraZOffset)
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


    
   
}
