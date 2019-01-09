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
    @IBOutlet weak var startingPointButton: UIButton!
    @IBOutlet weak var endingPointButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
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
    @IBAction func startingPointButtonTapped(_ sender: UIButton) {
        //add a block to the 3D world when the user taps
        let userTouch = sceneView.center
        
        //where is the touch in the AR scene
        let testResults = sceneView.hitTest(userTouch, types: .featurePoint)
        
        if let theResult = testResults.first {
            //create a block in AR World
            let box = SCNBox(width: 0.005, height: 0.005, length: 0.005, chamferRadius: 0.005)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            box.firstMaterial = material
            
            let boxNode = SCNNode(geometry: box)
            let boxX = theResult.worldTransform.columns.3.x
            let boxY = theResult.worldTransform.columns.3.y
            let boxZ = theResult.worldTransform.columns.3.z
            
            boxNode.position = SCNVector3(boxX, boxY, boxZ)
            
            //add the box to the world
            sceneView.scene.rootNode.addChildNode(boxNode)
        }
    }
    
    @IBAction func endingPointButtonTapped(_ sender: UIButton) {
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
