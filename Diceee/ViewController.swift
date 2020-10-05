//
//  ViewController.swift
//  Diceee
//
//  Created by Gnanpriya C on 21/06/20.
//  Copyright © 2020 Gnanpriya C. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    var condition = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
//MARK:- Creating and adding new ARobjects
        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //        // Set the scene to the view
        //        sceneView.scene = scene
//MARK:- Create objects
        //        let object = SCNSphere(radius: 0.1)
        //
        //        let material = SCNMaterial()
        //
        //        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
        //
        //        object.materials = [material]
        //
        //        let node = SCNNode()
        //
        //        node.position = SCNVector3(0, 0.2, -0.5)
        //
        //        node.geometry = object
        //
        //        sceneView.scene.rootNode.addChildNode(node)
        //        sceneView.autoenablesDefaultLighting = true
//MARK:- Add dice from model
        //        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")
        //
        //        if let node = scene?.rootNode.childNode(withName: "Dice", recursively: true){
        //
        //            node.position = SCNVector3(x: 0, y: 0, z: -0.2)
        //
        //            sceneView.scene.rootNode.addChildNode(node)
        //        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func rollAction(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //1. Get The Current Touch Point
        guard let currentTouchPoint = touches.first?.location(in: sceneView) else {
            return
        }
            //2. Get The Next Feature Point Etc
            guard let hitTest = sceneView.hitTest(currentTouchPoint, types: .existingPlane).first else { return }

        //3. Convert To World Coordinates
        let worldTransform = hitTest.worldTransform
        
        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")
        if condition {
        if let diceNode = scene?.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y + diceNode.boundingSphere.radius, worldTransform.columns.3.z)
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
            condition = false
        }
        }

        //4. Set The New Position
        let newPosition = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)

        //5. Apply To The Node
        for dice in diceArray {
        dice.simdPosition = SIMD3(newPosition.x, newPosition.y, newPosition.z)
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * Float.pi / 2
        let randomY = Float(arc4random_uniform(4) + 1) * Float.pi / 2
        let sceneAction = SCNAction.rotateBy(x: CGFloat(randomX), y: 0, z: CGFloat(randomY), duration: 0.5)
        dice.runAction(sceneAction)
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        condition = true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let planeAnchor = anchor as! ARPlaneAnchor
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        //planeAnchor.extent.x - estimated width and height of plane
//        planeNode.position = SCNVector3(planeAnchor.extent.x, 0, planeAnchor.extent.z)
        //planes are generally vertically we need to transform it as horizontal
        //Using -Float.pi to rotate clockwise
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        //plane.materials = [material]
        planeNode.geometry = plane
        //node.addChildNode(planeNode)
    }
    
}
