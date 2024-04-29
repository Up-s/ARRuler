//
//  ViewController.swift
//  ARRuler
//
//  Created by YouUp Lee on 4/30/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
  
  // MARK: - Property
  
  @IBOutlet var sceneView: ARSCNView!
  
  private var nodeArray = [SCNNode]()
  
  
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    self.sceneView.delegate = self
    
    self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    // Run the view's session
    self.sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    self.sceneView.session.pause()
  }
  
  
  
  // MARK: - Touch
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let touchLocation = touch.location(in: self.sceneView)
    
    guard let query = self.sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) else { return }
    let results = self.sceneView.session.raycast(query)
    self.addDot(results)
  }
  
  
  
  // MARK: - Action
  
  @IBAction func trashDidTap(_ sender: UIButton) {
    self.nodeArray.forEach { $0.removeFromParentNode() }
    self.nodeArray.removeAll()
  }
  
  
  
  // MARK: - Interface
  
  private func addDot(_ results: [ARRaycastResult]) {
    guard let hitResult = results.first else { return }
    
    let meterial = SCNMaterial()
    meterial.diffuse.contents = UIColor.red
    
    let dotGeometry = SCNSphere(radius: 0.005)
    dotGeometry.materials = [meterial]
    
    let dotNode = SCNNode(geometry: dotGeometry)
    dotNode.position = SCNVector3(
      x: hitResult.worldTransform.columns.3.x,
      y: hitResult.worldTransform.columns.3.y,
      z: hitResult.worldTransform.columns.3.z
    )
    
    self.sceneView.scene.rootNode.addChildNode(dotNode)
    
    self.nodeArray.append(dotNode)
    
    guard self.nodeArray.count >= 2 else { return }
    
    self.calculateNode()
  }
  
  private func calculateNode() {
    let start = self.nodeArray[0]
    let end = self.nodeArray[1]
    
    let a = end.position.x - start.position.x
    let b = end.position.y - start.position.y
    let c = end.position.z - start.position.z
    
    let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 3))
    self.updateText(distance: distance, position: end.position)
  }
  
  private func updateText(distance: Float, position: SCNVector3) {
    let text = "\(distance * 100)cm"
    
    let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
    textGeometry.firstMaterial?.diffuse.contents = UIColor.red
    
    let textNode = SCNNode (geometry: textGeometry)
    textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
    textNode.scale = SCNVector3(0.005, 0.005, 0.005)
    
    self.sceneView.scene.rootNode.addChildNode(textNode)
    
    self.nodeArray.append(textNode)
  }
}
