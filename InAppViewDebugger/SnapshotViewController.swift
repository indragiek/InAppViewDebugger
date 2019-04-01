//
//  SnapshotViewController.swift
//  LiveSnapshot
//
//  Created by Indragie Karunaratne on 3/30/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit
import SceneKit

let borderColor = UIColor.darkGray
let headerVerticalInset: CGFloat = 8.0
let headerColor = UIColor.darkGray
let headerCornerRadius: CGFloat = 8.0
let headerFont = UIFont.boldSystemFont(ofSize: 13)
let headerOpacity: CGFloat = 0.8

public func nodeForElement(element: Element, parentElement: Element?, rootNode: SCNNode, parentNode: SCNNode?, depth: inout Int, zSpacing: CGFloat) -> SCNNode? {
    // Ignore elements that are not visible. These should appear in
    // the tree view, but not in the 3D view.
    if element.isHidden || element.frame.size == .zero {
        return nil
    }
    
    // Create a node whose contents are the snapshot of the element.
    let node = SCNNode(geometry: snapshotShape(element: element))
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
    addBorder(node: node, color: borderColor)
    
    if let headerNode = nameHeaderNode(element: element, associatedSnapshotNode: node) {
        parentNode?.addChildNode(headerNode)
    }
    
    return node
}

fileprivate func nameHeaderNode(element: Element, associatedSnapshotNode: SCNNode) -> SCNNode? {
    guard let text = nameTextGeometry(element: element) else {
        return nil
    }
    
    let textNode = SCNNode(geometry: text)
    let (min, max) = textNode.boundingBox
    let textWidth = max.x - min.x
    let textHeight = max.y - min.y
    
    let frame = CGRect(x: 0.0, y: 0.0, width: element.frame.width, height: CGFloat(textHeight) + (headerVerticalInset * 2.0))
    let headerNode = SCNNode(geometry: nameHeaderShape(frame: frame))
    
    textNode.position = SCNVector3((Float(frame.width) / 2.0) - (textWidth / 2.0), (Float(frame.height) / 2.0) - (textHeight / 2.0), 0.5)
    headerNode.addChildNode(textNode)
    
    let snapshotPosition = associatedSnapshotNode.position
    headerNode.position = SCNVector3(snapshotPosition.x, snapshotPosition.y + Float(element.frame.height), associatedSnapshotNode.position.z + 0.5)
    headerNode.opacity = headerOpacity
    return headerNode
}

fileprivate func nameHeaderShape(frame: CGRect) -> SCNShape {
    let path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: headerCornerRadius, height: headerCornerRadius))
    let shape = SCNShape(path: path, extrusionDepth: 0.0)
    let material = SCNMaterial()
    material.isDoubleSided = true
    material.diffuse.contents = headerColor
    shape.insertMaterial(material, at: 0)
    return shape
}

fileprivate func nameTextGeometry(element: Element) -> SCNText? {
    guard let name = element.viewDebuggerName else {
        return nil
    }
    let text = SCNText()
    text.string = name
    text.font = headerFont
    text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
    text.truncationMode = CATextLayerTruncationMode.end.rawValue
    return text
}

fileprivate func snapshotShape(element: Element) -> SCNShape {
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
    return shape
}

fileprivate func lineFrom(vertex vertex1: SCNVector3, toVertex vertex2: SCNVector3, color: UIColor) -> SCNNode
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
    
    let bottom = lineFrom(vertex: bottomLeft, toVertex: bottomRight, color: color)
    node.addChildNode(bottom)
    
    let left = lineFrom(vertex: bottomLeft, toVertex: topLeft, color: color)
    node.addChildNode(left)
    
    let right = lineFrom(vertex: bottomRight, toVertex: topRight, color: color)
    node.addChildNode(right)
    
    let top = lineFrom(vertex: topLeft, toVertex: topRight, color: color)
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
        scene.background.contents = UIColor.white
        scene.rootNode.addChildNode(node)
        sceneView?.scene = scene
        sceneView?.allowsCameraControl = true
    }
    
}
