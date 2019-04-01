//
//  SnapshotViewController.swift
//  LiveSnapshot
//
//  Created by Indragie Karunaratne on 3/30/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit
import SceneKit

public func nodeForElement(element: Element, parentElement: Element?, rootNode: SCNNode, parentNode: SCNNode?, depth: inout Int, zSpacing: CGFloat) -> SCNNode? {
    // Ignore elements that are not visible. These should appear in
    // the tree view, but not in the 3D view.
    if element.isHidden || element.frame.size == .zero {
        return nil
    }
    
    // Create a node whose contents are the snapshot of the element.
    let path = UIBezierPath(rect: CGRect(origin: .zero, size: element.frame.size))
    let shape = SCNShape(path: path, extrusionDepth: 0.0)
    let material = SCNMaterial()
    material.isDoubleSided = true
    if let snapshot = element.snapshot {
        material.diffuse.contents = snapshot
    } else {
        material.diffuse.contents = UIColor.white
    }
    shape.insertMaterial(material, at: 0)
    let node = SCNNode(geometry: shape)
    parentNode?.addChildNode(node)
    
    // The z-coordinate is calculated by multiplying the specified
    // spacing between layers by the depth of the layer. This gives us
    // a z value that is in the coordinate space of the root node, which
    // then has to be converted to a coordinate in the local coordinate
    // space of the node we just created.
    let zInRootCoordinateSpace = zSpacing * CGFloat(depth)
    let z = rootNode.convertPosition(SCNVector3(0, 0, zInRootCoordinateSpace), to: node).z
    
    // Flip the y-coordinate since the SceneKit coordinate system has
    // a flipped version of the UIKit coordinate system.
    let y: CGFloat
    if let parentElement = parentElement {
        y = parentElement.frame.height - element.frame.maxY
    } else {
        y = 0.0
    }
    node.position = SCNVector3(element.frame.origin.x, y, CGFloat(z))
    
    var frames = [CGRect]()
    var maxChildDepth = depth
    element.children.forEach { child in
        var childDepth: Int
        // Children that intersect a sibling should be rendered in
        // a separate layer, above the previous siblings.
        if frames.first(where: { $0.intersects(child.frame) }) != nil {
            childDepth = maxChildDepth + 1
        } else {
            childDepth = depth + 1
        }
        
        if let childNode = nodeForElement(element: child, parentElement: element, rootNode: rootNode, parentNode: node, depth: &childDepth, zSpacing: zSpacing) {
            maxChildDepth = max(maxChildDepth, childDepth)
            frames.append(child.frame)
            node.addChildNode(childNode)
        }
    }
    depth = maxChildDepth
    addBorder(node: node, color: .white)
    return node
}

fileprivate func lineFrom(vertex1: SCNVector3, vertex2: SCNVector3, color: UIColor) -> SCNNode
{
    let indices: [Int32] = [0, 1]
    let source = SCNGeometrySource(vertices: [vertex1, vertex2])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    
    let geometry = SCNGeometry(sources: [source], elements: [element])
    let material = SCNMaterial()
    material.diffuse.contents = color
    material.isDoubleSided = true
    geometry.insertMaterial(material, at: 0)
    
    return SCNNode(geometry: geometry)
}

fileprivate func addBorder(node: SCNNode, color: UIColor) {
    let (min, max) = node.boundingBox;
    
    // This value is chosen so that the border visually appears on
    // top of the node, but is offset slightly on the z-axis to avoid
    // z-fighting.
    let z: Float = 0.5
    let topLeft = SCNVector3(min.x, max.y, z)
    let bottomLeft = SCNVector3(min.x, min.y, z)
    let topRight = SCNVector3(max.x, max.y, z)
    let bottomRight = SCNVector3(max.x, min.y, z)
    
    let bottom = lineFrom(vertex1: bottomLeft, vertex2: bottomRight, color: color)
    node.addChildNode(bottom)
    
    let left = lineFrom(vertex1: bottomLeft, vertex2: topLeft, color: color)
    node.addChildNode(left)
    
    let right = lineFrom(vertex1: bottomRight, vertex2: topRight, color: color)
    node.addChildNode(right)
    
    let top = lineFrom(vertex1: topLeft, vertex2: topRight, color: color)
    node.addChildNode(top)
}

public class SnapshotViewController: UIViewController {
    private let node: SCNNode
    var sceneView: SCNView?
    
    public init(node: SCNNode) {
        self.node = node
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override public func loadView() {
        let sceneView = SCNView(frame: .zero)
        self.sceneView = sceneView
        self.view = sceneView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene()
        scene.background.contents = UIColor(red:0.251, green:0.251, blue:0.251, alpha:1.000)
        scene.rootNode.addChildNode(node)
        sceneView?.scene = scene
        sceneView?.allowsCameraControl = true
    }
    
}
