//
//  ViewController.swift
//  ARKit Intro
//
//  Created by Charles Martin Reed on 1/9/19.
//  Copyright © 2019 Charles Martin Reed. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    //MARK:- IBOutlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var measurementLabel: UILabel!
    @IBOutlet weak var measureButton: UIButton!
    
    //MARK:- Properties
    var firstBox: SCNNode?
    var secondBox: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        measurementLabel.text = "Select first point"
        measureButton.isEnabled = false
        measureButton.alpha = 0.5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //for now, just detecting flat surfaces like tables. The vertical option is for detecting surfaces like walls.
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK:- IBActions
    @IBAction func measureButtonTapped(_ sender: UIButton) {
        if firstBox != nil && secondBox != nil {
            calcDistance()
            measureButton.setTitle("Reset", for: .normal)
        }

        if sender.titleLabel?.text == "Reset" {
            resetBoxPoints()
            measureButton.setTitle("Measure", for: .normal)
        }
    }
    
    //MARK:- Placing box objects in the ARScene
    func createBoxAt(point: CGPoint) {
        //add a block to the 3D world when the user taps
        
        if firstBox == nil {
            //where is the touch in the AR scene
            let testResults = sceneView.hitTest(point, types: .featurePoint)
            
            if let theResult = testResults.first {
                //create a block in AR World
                let box = SCNBox(width: 0.005, height: 0.005, length: 0.005, chamferRadius: 0.005)
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.green
                box.firstMaterial = material
                
                let boxNode = SCNNode(geometry: box)
                boxNode.name = "measurePoint"
                let boxX = theResult.worldTransform.columns.3.x
                let boxY = theResult.worldTransform.columns.3.y
                let boxZ = theResult.worldTransform.columns.3.z
                
                boxNode.position = SCNVector3(boxX, boxY, boxZ)
                
                //add the box to the world
                firstBox = boxNode
                sceneView.scene.rootNode.addChildNode(firstBox!)
                measurementLabel.text = "Select second point"
            }
        } else if secondBox == nil {
            //where is the touch in the AR scene
            let testResults = sceneView.hitTest(point, types: .featurePoint)
            
            if let theResult = testResults.first {
                //create a block in AR World
                let box = SCNBox(width: 0.005, height: 0.005, length: 0.005, chamferRadius: 0.005)
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.green
                box.firstMaterial = material
                
                let boxNode = SCNNode(geometry: box)
                boxNode.name = "measurePoint"
                let boxX = theResult.worldTransform.columns.3.x
                let boxY = theResult.worldTransform.columns.3.y
                let boxZ = theResult.worldTransform.columns.3.z
                
                boxNode.position = SCNVector3(boxX, boxY, boxZ)
                
                //add the box to the world
                secondBox = boxNode
                sceneView.scene.rootNode.addChildNode(secondBox!)
                
                //enable the measurement button
                measurementLabel.text = "Click measure button"
                measureButton.isEnabled = true
                measureButton.alpha = 1.0
                //return boxNode
            } else if firstBox != nil && secondBox != nil {
                return
            }
        }
        
    }
    
    //MARK:- Calculating the distance between two points
    func calcDistance() {
        guard let firstBox = firstBox else { return }
        guard let secondBox = secondBox else { return }
        
        //using the pythagorean theorem to figure out our distance
        let vector = SCNVector3Make(secondBox.position.x - firstBox.position.x, secondBox.position.y - firstBox.position.y, secondBox.position.z - firstBox.position.z)
        
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z) * 39.37 //inches
        updateDistanceLabel(distance: "\(distance) inches")
    }
    
    //MARK:- Updating the UI
    func updateDistanceLabel(distance: String) {
        measurementLabel.text = "\(distance)"
    }
    
    //MARK:- Resetting the scene for new measurements
    func resetBoxPoints() {
        for node in sceneView.scene.rootNode.childNodes {
            if node.name == "measurePoint" {
                //could obviously handle this with direct calls to the two nodes, but leaving this in allows for the flexibility of measuring multiple points in the future
                node.removeFromParentNode()
            }
        }
        updateDistanceLabel(distance: "")
        
        //reset the measure button
        measureButton.isEnabled = false
        measureButton.alpha = 0.5
        
        //nil the values
        firstBox = nil
        secondBox = nil
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first else { return }
        let touchLocation = touchPoint.location(in: sceneView)
        
        createBoxAt(point: touchLocation)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        //when a surface is found, a node will be added
//        print("added node")
//
//        //how big was the thing we just found? Check the anchor
//        if let plane = anchor as? ARPlaneAnchor {
//            print("X: \(plane.extent.x)m, Z: \(plane.extent.z)")
//        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let plane = anchor as? ARPlaneAnchor {
//            print("X: \(plane.extent.x)m, Z: \(plane.extent.z)")
//        }
    }
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
