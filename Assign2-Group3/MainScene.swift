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
    var mapNode = SCNNode()
    var cameraXOffset: Float = 4.5
    var cameraYOffset: Float = 20
    var cameraZOffset: Float = 5
    var rotAngle = 0.0
    let mazeWrapper: MazeWrapper = MazeWrapper(rows: 10, columns: 10)
    var touched = false
    var fog = false
    var flashlightOn = false
    var daylight = true
    var console = false
    var ambientLight = SCNNode()
    var spotlight = SCNNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Initializer
    override init() {
        super.init()
        
        background.contents = UIColor.black
        
        setupCamera()
        setupLight()
        addMazeToScene()

        setupFog()
        setupFlashlight()

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
        // Moves camera to player on first touch
        if (!touched) {
            cameraNode.position = SCNVector3(0,0,-1)
            cameraNode.eulerAngles = SCNVector3(0,-Float.pi,0)
            touched = true
        }
        if (cameraZOffset * 1000 < 2 && cameraZOffset * 1000 > -2 && cameraXOffset != 0) {
            if (cameraNode.eulerAngles.y < Float.pi || cameraNode.eulerAngles.y > -3*Float.pi) {
                cameraNode.eulerAngles = SCNVector3(0, cameraNode.eulerAngles.y + cameraXOffset, 0)
                if (console) {
                    mapNode.childNode(withName: "Player Orientation", recursively: true)!.eulerAngles = SCNVector3(mapNode.eulerAngles.x, cameraNode.eulerAngles.y + cameraXOffset, mapNode.eulerAngles.z)
                }
            } else {
                cameraNode.eulerAngles = SCNVector3(0,-Float.pi,0)
                if (console) {
                    mapNode.childNode(withName: "Player Orientation", recursively: true)!.eulerAngles = SCNVector3(cameraNode.eulerAngles.x, -Float.pi, cameraNode.eulerAngles.z)
                    mapNode.position = SCNVector3(cameraNode.position.x, mapNode.position.y, cameraNode.position.z)
                }
            }
        }
        else {
            cameraNode.position = SCNVector3(cameraNode.position.x + cameraXOffset, 0, cameraNode.position.z + cameraZOffset)
            if (console) {
                mapNode.childNode(withName: "Player Position", recursively: true)!.position = SCNVector3(mapNode.childNode(withName: "Player Position", recursively: true)!.position.x + cameraXOffset * 0.1, mapNode.childNode(withName: "Player Position", recursively: true)!.position.y, mapNode.childNode(withName: "Player Position", recursively: true)!.position.z + cameraZOffset * 0.1)
                mapNode.childNode(withName: "Player Orientation", recursively: true)!.position = SCNVector3(mapNode.childNode(withName: "Player Orientation", recursively: true)!.position.x + cameraXOffset * 0.1, mapNode.childNode(withName: "Player Orientation", recursively: true)!.position.y, mapNode.childNode(withName: "Player Orientation", recursively: true)!.position.z + cameraZOffset * 0.1)
            }
        }
    }
    
    func resetCameraPosition() {
        cameraNode.position = SCNVector3(0,0,-1)
        cameraNode.eulerAngles = SCNVector3(0,-Float.pi,0)
        if (console) {
            mapNode.childNode(withName: "Player Position", recursively: true)!.position = SCNVector3(cameraNode.position.x * 0.1, mapNode.childNode(withName: "Player Position", recursively: true)!.position.y, cameraNode.position.z * 0.1)
            mapNode.childNode(withName: "Player Orientation", recursively: true)!.position = SCNVector3(cameraNode.position.x * 0.1, mapNode.childNode(withName: "Player Orientation", recursively: true)!.position.y, cameraNode.position.z * 0.1 + 0.03)
            mapNode.childNode(withName: "Player Orientation", recursively: true)!.eulerAngles = SCNVector3(mapNode.eulerAngles.x, cameraNode.eulerAngles.y, mapNode.eulerAngles.z)
        }
    }
  
    func setupLight(){
        
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = UIColor.white
        ambientLight.light!.intensity = 1000
        rootNode.addChildNode(ambientLight)
        spotlight.light = SCNLight()//If I don't add another non-ambient light into the scene it doesn't diable the default ambient light
        spotlight.light?.type = .directional
        spotlight.light?.intensity = 0
        rootNode.addChildNode(spotlight)
        
    }
    
    // MAZE // ////////////
    func addMazeToScene() {
        mazeWrapper.createMaze()
            
        let cellSize: CGFloat = 1.0
            
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
                        var leftWall = false
                        var rightWall = false
                        // Adjust dimensions and position for different directions
                        switch direction {
                        case .dNORTH:
                            width = cellSize
                            length = 0.1
                            positionAdjustment = SCNVector3(0, 0, -cellSize/2+0.01)
                            if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 3)){
                                leftWall = true
                            }
                            if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 1)){
                                rightWall = true
                            }
                        case .dEAST:
                            width = 0.1
                            length = cellSize
                            positionAdjustment = SCNVector3(cellSize/2-0.01, 0, 0)
                            if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 0)){
                                leftWall = true
                            }
                            if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 2)){
                                rightWall = true
                            }
                        case .dSOUTH:
                            width = cellSize
                            length = 0.1
                            positionAdjustment = SCNVector3(0, 0, cellSize/2-0.01)
                            if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 1)){
                                leftWall = true
                            }
                            if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 3)){
                                rightWall = true
                            }
                        case .dWEST:
                            width = 0.1
                            length = cellSize
                            positionAdjustment = SCNVector3(-cellSize/2+0.01, 0, 0)
                            if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 2)){
                                leftWall = true
                            }
                            if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 0)){
                                rightWall = true
                            }
                        }
                        
                        let texture : UIImage?
                        
                        if(!leftWall && !rightWall){
                            texture = UIImage(named: "stonewall.jpeg")
                        }else if(leftWall && !rightWall){
                            texture = UIImage(named: "brickwall.jpg")
                        }else if(!leftWall && rightWall){
                            texture = UIImage(named: "stone.jpg")
                        }else{
                            texture = UIImage(named: "wood.avif")
                        }
                        
                        let material = SCNMaterial()
                        material.diffuse.contents = texture
                        
                        let wallGeometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
                        wallGeometry.materials = [material] // Apply material to geometry
                        let wallNode = SCNNode(geometry: wallGeometry)
                        wallNode.position = SCNVector3Make(position.x + positionAdjustment.x, position.y + positionAdjustment.y, position.z + positionAdjustment.z)
                        
                        mazeNode.addChildNode(wallNode)
                    }
                    
                    let floorGeometry = SCNBox(width: cellSize, height: 0.01, length: cellSize, chamferRadius: 0)
                    let floorMaterial = SCNMaterial()
                    floorMaterial.diffuse.contents = UIImage(named: "grass.avif")
                    floorGeometry.materials = [floorMaterial]
                    let floorNode = SCNNode(geometry: floorGeometry)
                    floorNode.position = SCNVector3Make(position.x, position.y - Float(cellSize/2), position.z)
                    mazeNode.addChildNode(floorNode)
                }
                
            }
        }
            
            rootNode.addChildNode(mazeNode)
        }


    func setupFog() {
        fogColor = UIColor.white
        fogStartDistance = 0.0
        fogEndDistance = 0.0
        fogDensityExponent = 2.0
    }
    
    func toggleFog(distance: CGFloat, density: CGFloat) {
        if (!fog) {
            fogEndDistance = distance
            fogDensityExponent = density
            fog = true
        } else {
            fogEndDistance = 0.0
            fog = false
        }
    }

    func toggleDaylight(){
        if(daylight){
            ambientLight.light?.intensity = 100
        }else{
            ambientLight.light?.intensity = 1000
        }
        daylight = !daylight

    }
    
    func setupFlashlight() {
        cameraNode.light = SCNLight()
        cameraNode.light!.color = UIColor.white
        cameraNode.light!.intensity = 0
        cameraNode.light!.type = .spot
    }
    
    func toggleFlashlight() {
        if (flashlightOn) {
            cameraNode.light!.intensity = 0;
            flashlightOn = false
        }
        else {
            cameraNode.light!.intensity = 5000;
            flashlightOn = true
        }
    }
   
    func createMiniMaze() {
        
    let cellSize: CGFloat = 0.1
        
    let playerPosition = cameraNode.position
    let playerRotation = cameraNode.eulerAngles
        
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
                    var leftWall = false
                    var rightWall = false
                    // Adjust dimensions and position for different directions
                    switch direction {
                    case .dNORTH:
                        width = cellSize
                        length = 0.01
                        positionAdjustment = SCNVector3(0, 0, -cellSize/2+0.01)
                        if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 3)){
                            leftWall = true
                        }
                        if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 1)){
                            rightWall = true
                        }
                    case .dEAST:
                        width = 0.01
                        length = cellSize
                        positionAdjustment = SCNVector3(cellSize/2-0.01, 0, 0)
                        if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 0)){
                            leftWall = true
                        }
                        if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 2)){
                            rightWall = true
                        }
                    case .dSOUTH:
                        width = cellSize
                        length = 0.01
                        positionAdjustment = SCNVector3(0, 0, cellSize/2-0.01)
                        if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 1)){
                            leftWall = true
                        }
                        if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 3)){
                            rightWall = true
                        }
                    case .dWEST:
                        width = 0.01
                        length = cellSize
                        positionAdjustment = SCNVector3(-cellSize/2+0.01, 0, 0)
                        if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 2)){
                            leftWall = true
                        }
                        if(mazeWrapper.isWallPresent(atRow: row, column: col, direction: 0)){
                            rightWall = true
                        }
                    }
                    
                    let texture : UIImage?
                    
                    if(!leftWall && !rightWall){
                        texture = UIImage(named: "stonewall.jpeg")
                    }else if(leftWall && !rightWall){
                        texture = UIImage(named: "brickwall.jpg")
                    }else if(!leftWall && rightWall){
                        texture = UIImage(named: "stone.jpg")
                    }else{
                        texture = UIImage(named: "wood.avif")
                    }
                    
                    let material = SCNMaterial()
                    material.diffuse.contents = texture
                    
                    let wallGeometry = SCNBox(width: width, height: 0.01, length: length, chamferRadius: 0)
                    wallGeometry.materials = [material] // Apply material to geometry
                    let wallNode = SCNNode(geometry: wallGeometry)
                    wallNode.position = SCNVector3Make(position.x + positionAdjustment.x, position.y + positionAdjustment.y, position.z + positionAdjustment.z)
                    
                    mapNode.addChildNode(wallNode)
                }
            }
            
        }
    }
        mapNode.childNode(withName: "Player Position", recursively: true)?.removeFromParentNode()
        let characterGeometry = SCNSphere(radius: 0.01)
        let characterMaterial = SCNMaterial()
        characterMaterial.diffuse.contents = UIColor.red
        characterGeometry.materials = [characterMaterial]
        let characterNode = SCNNode(geometry: characterGeometry)
        characterNode.position = SCNVector3Make(playerPosition.x * 0.1, playerPosition.y, playerPosition.z * 0.1)
        characterNode.name = "Player Position"
        mapNode.addChildNode(characterNode)
        
        mapNode.childNode(withName: "Player Orientation", recursively: true)?.removeFromParentNode()
        let orientationGeometry = SCNCone(topRadius: 0.01, bottomRadius: 0.05, height: 0.05)
        let orientationMaterial = SCNMaterial()
        orientationMaterial.diffuse.contents = UIColor.blue
        orientationGeometry.materials = [orientationMaterial]
        let orientationNode = SCNNode(geometry: orientationGeometry)
        orientationNode.position = SCNVector3Make(playerPosition.x * 0.1, playerPosition.y, playerPosition.z * 0.1 + 0.03)
        orientationNode.eulerAngles = SCNVector3(Float.pi / 2, playerRotation.y, playerRotation.z)
        orientationNode.name = "Player Orientation"
        mapNode.addChildNode(orientationNode)
    }
    func toggleConsole() {
        if (!console) {
            let playerPosition = cameraNode.position
            let playerRotation = cameraNode.eulerAngles
            createMiniMaze()
            cameraNode.addChildNode(mapNode)
            mapNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
            mapNode.position = SCNVector3(-0.45, 0.5, -2)
            mapNode.opacity = 0.5
            console = true
        }
        else {
            mapNode.removeFromParentNode()
            console = false
        }
    }
}
