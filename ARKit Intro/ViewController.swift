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
        
        // this delegate allows us to save our AR scene
        sceneView.session.delegate = self
        
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

        //check for an old AR map in User Defaults
        if let mapData = UserDefaults.standard.data(forKey: "ARMap") {
            if let map = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: mapData) {
                //if we're here, we had an old map. Set it to the initial world map using configuration.
                configuration.initialWorldMap = map
            }
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK:- AR Session Delegate protocol methods
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //checks where the map is
        if frame.worldMappingStatus == .mapped {
            print("Mapping is complete")
        } else {
            print("Mapping in progress")
        }
    }
    
    func saveARMapping() {
        //grab the current map
        sceneView.session.getCurrentWorldMap { (map, error) in
            if let err = error {
                fatalError("Unable to get current map: \(err.localizedDescription)")
            }
            if let map = map {
                //use NSKeyedArchiver in order to prepare data for save to NSUserDefaults
                if let mapData = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) {
                    UserDefaults.standard.set(mapData, forKey: "ARMap")
                }
            }
        }
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
            let testResults = sceneView.hitTest(point, types: .featurePoint) //point detected by ARKit as a continuous surface
            
            if let theResult = testResults.first {
                firstBox = addSphere(at: theResult)
                sceneView.scene.rootNode.addChildNode(firstBox!)
                measurementLabel.text = "Select second point"
            }
        } else if secondBox == nil {
            //where is the touch in the AR scene
            let testResults = sceneView.hitTest(point, types: .featurePoint)
            
            if let theResult = testResults.first {
                secondBox = addSphere(at: theResult)
                sceneView.scene.rootNode.addChildNode(secondBox!)
                
                measurementLabel.text = "Click measure button"
                measureButton.isEnabled = true
                measureButton.alpha = 1.0
                
                //save the points on the map
                saveARMapping()
            } else if firstBox != nil && secondBox != nil {
                return
            }
        }
        
    }
    
    func addSphere(at hitResult: ARHitTestResult) -> SCNNode {
        
        let dotGeometry = SCNSphere(radius: 0.005) //about half a centimenter in radius
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.name = "measurePoint"
        
        let xPos = hitResult.worldTransform.columns.3.x
        let yPos = hitResult.worldTransform.columns.3.y
        let zPos = hitResult.worldTransform.columns.3.z
        dotNode.position = SCNVector3(xPos, yPos, zPos)
        
        return dotNode
    }
    
    
    
    //MARK:- Calculating the distance between two points
    func calcDistance() {
        guard let firstBox = firstBox else { return }
        guard let secondBox = secondBox else { return }
        
        //each vector has an X, Y and Z coordinate
        //in a 3D space, figuring out a space rr
        
        //using a variant of the pythagorean theorem to figure out our distance in 3d space
        //d = sqrt(a*a + b*b + c*c), where d = distance and a, b, c are vector points in that 3d space
        let a = secondBox.position.x - firstBox.position.x
        let b = secondBox.position.y - firstBox.position.y
        let c = secondBox.position.z - firstBox.position.z
        
        //let vector = SCNVector3Make(a, b, c)
        
        //now, we can use pythogorean theorem to work out the distance
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        //let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        updateDistanceLabel(distance: "\(distance) meters")
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

extension ViewController : ARSessionDelegate {
    
}
