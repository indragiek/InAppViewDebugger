//
//  SnapshotView.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 3/31/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit
import SceneKit

/// A view that renders an interactive 3D representation of a UI element
/// hierarchy snapshot.
class SnapshotView: UIView {
    private let configuration: SnapshotViewConfiguration
    private let snapshot: Snapshot
    private let sceneView: SCNView
    private var snapshotIdentifierToNodesMap = [String: SnapshotNodes]()
    
    public init(snapshot: Snapshot, configuration: SnapshotViewConfiguration = SnapshotViewConfiguration()) {
        self.configuration = configuration
        self.snapshot = snapshot
        sceneView = SCNView()
        
        super.init(frame: .zero)
        addSubview(sceneView)
        
        let scene = SCNScene()
        scene.background.contents = configuration.backgroundColor
        
        var depth = 0
        _ = snapshotNode(snapshot: snapshot,
                         parentSnapshot: nil,
                         rootNode: scene.rootNode,
                         parentNode: scene.rootNode,
                         depth: &depth,
                         snapshotIdentifierToNodesMap: &snapshotIdentifierToNodesMap,
                         configuration: configuration)
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sceneView.frame = bounds
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(ofTouch: 0, in: sceneView)
            let hitTestResult = sceneView.hitTest(point, options: nil)
            for result in hitTestResult {
                print(result.node)
            }
        }
    }
}

private struct SnapshotNodes {
    let snapshot: Snapshot
    weak var snapshotNode: SCNNode?
    weak var headerNode: SCNNode?
    weak var borderNode: SCNNode?
    
    init(snapshot: Snapshot) {
        self.snapshot = snapshot
    }
}

private func snapshotNode(snapshot: Snapshot,
                          parentSnapshot: Snapshot?,
                          rootNode: SCNNode,
                          parentNode: SCNNode?,
                          depth: inout Int,
                          snapshotIdentifierToNodesMap: inout [String: SnapshotNodes],
                          configuration: SnapshotViewConfiguration) -> SCNNode? {
    // Ignore elements that are not visible. These should appear in
    // the tree view, but not in the 3D view.
    if snapshot.isHidden || snapshot.frame.size == .zero {
        return nil
    }
    var nodes = SnapshotNodes(snapshot: snapshot)
    
    // Create a node whose contents are the snapshot of the element.
    let node = SCNNode(geometry: snapshotShape(snapshot: snapshot))
    node.name = snapshot.identifier
    nodes.snapshotNode = node
    
    // The node must be added to the parent node for the coordinate
    // space calculations below to work.
    parentNode?.addChildNode(node)
    
    // The z-coordinate is calculated by multiplying the specified
    // spacing between layers by the depth of the layer. This gives us
    // a z value that is in the coordinate space of the root node, which
    // then has to be converted to a coordinate in the local coordinate
    // space of the node we just created.
    let zInRootCoordinateSpace = configuration.zSpacing * CGFloat(depth)
    let z = rootNode.convertPosition(SCNVector3(0, 0, zInRootCoordinateSpace), to: node).z
    
    // Flip the y-coordinate since the SceneKit coordinate system has
    // a flipped version of the UIKit coordinate system.
    let y: CGFloat
    if let parentSnapshot = parentSnapshot {
        y = parentSnapshot.frame.height - snapshot.frame.maxY
    } else {
        y = 0.0
    }
    node.position = SCNVector3(snapshot.frame.origin.x, y, CGFloat(z))
    
    let headerAttributes: SnapshotViewConfiguration.HeaderAttributes
    switch snapshot.label.classification {
    case .normal:
        headerAttributes = configuration.normalHeaderAttributes
    case .important:
        headerAttributes = configuration.importantHeaderAttributes
    }
    
    let border = borderNode(node: node, color: headerAttributes.color)
    border.name = snapshot.identifier
    node.addChildNode(border)
    nodes.borderNode = border
    
    if let header = headerNode(snapshot: snapshot,
                               associatedSnapshotNode: node,
                               attributes: headerAttributes) {
        header.name = snapshot.identifier
        parentNode?.addChildNode(header)
        nodes.headerNode = header
    }
    
    snapshotIdentifierToNodesMap[snapshot.identifier] = nodes
    
    var frames = [CGRect]()
    var maxChildDepth = depth
    snapshot.children.forEach { child in
        var childDepth: Int
        // Children that intersect a sibling should be rendered in
        // a separate layer, above the previous siblings.
        if frames.first(where: { $0.intersects(child.frame) }) != nil {
            childDepth = maxChildDepth + 1
        } else {
            childDepth = depth + 1
        }
        
        if let childNode = snapshotNode(snapshot: child,
                                        parentSnapshot: snapshot,
                                        rootNode: rootNode,
                                        parentNode: node,
                                        depth: &childDepth,
                                        snapshotIdentifierToNodesMap: &snapshotIdentifierToNodesMap,
                                        configuration: configuration) {
            maxChildDepth = max(maxChildDepth, childDepth)
            frames.append(child.frame)
            node.addChildNode(childNode)
        }
    }
    depth = maxChildDepth
    return node
}

/// Returns a shape that renders a snapshot image.
private func snapshotShape(snapshot: Snapshot) -> SCNShape {
    let path = UIBezierPath(rect: CGRect(origin: .zero, size: snapshot.frame.size))
    let shape = SCNShape(path: path, extrusionDepth: 0.0)
    let material = SCNMaterial()
    material.isDoubleSided = true
    if let snapshot = snapshot.snapshotImage {
        material.diffuse.contents = snapshot
    } else {
        material.diffuse.contents = UIColor.white
    }
    shape.insertMaterial(material, at: 0)
    return shape
}

/// Returns a node that draws a line between two vertices.
private func lineFrom(vertex vertex1: SCNVector3, toVertex vertex2: SCNVector3, color: UIColor) -> SCNNode
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

/// Returns an array of nodes that can be used to render a colored
/// border around the specified node.
private func borderNode(node: SCNNode, color: UIColor) -> SCNNode {
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
    let left = lineFrom(vertex: bottomLeft, toVertex: topLeft, color: color)
    let right = lineFrom(vertex: bottomRight, toVertex: topRight, color: color)
    let top = lineFrom(vertex: topLeft, toVertex: topRight, color: color)
    
    let border = SCNNode()
    border.addChildNode(bottom)
    border.addChildNode(left)
    border.addChildNode(right)
    border.addChildNode(top)
    return border
}

/// Returns a node that renders a header above a snapshot node.
/// The header contains the name text from the element, if specified.
private func headerNode(snapshot: Snapshot,
                        associatedSnapshotNode: SCNNode,
                        attributes: SnapshotViewConfiguration.HeaderAttributes) -> SCNNode? {
    guard let text = nameTextGeometry(label: snapshot.label, font: attributes.font) else {
        return nil
    }
    
    let textNode = SCNNode(geometry: text)
    let (min, max) = textNode.boundingBox
    let textWidth = max.x - min.x
    let textHeight = max.y - min.y
    
    let frame = CGRect(x: 0.0, y: 0.0, width: snapshot.frame.width, height: CGFloat(textHeight) + (attributes.verticalInset * 2.0))
    let headerNode = SCNNode(geometry: nameHeaderShape(frame: frame, color: attributes.color, cornerRadius: attributes.cornerRadius))
    
    textNode.position = SCNVector3((Float(frame.width) / 2.0) - (textWidth / 2.0), (Float(frame.height) / 2.0) - (textHeight / 2.0), 0.5)
    headerNode.addChildNode(textNode)
    
    let snapshotPosition = associatedSnapshotNode.position
    headerNode.position = SCNVector3(snapshotPosition.x, snapshotPosition.y + Float(snapshot.frame.height), associatedSnapshotNode.position.z + 0.5)
    headerNode.opacity = attributes.opacity
    return headerNode
}

/// Returns a shape that is used to render the background of the header.
private func nameHeaderShape(frame: CGRect, color: UIColor, cornerRadius: CGFloat) -> SCNShape {
    let path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    let shape = SCNShape(path: path, extrusionDepth: 0.0)
    let material = SCNMaterial()
    material.isDoubleSided = true
    material.diffuse.contents = color
    shape.insertMaterial(material, at: 0)
    return shape
}

/// Returns a text geometry used to render text inside the header.
private func nameTextGeometry(label: ElementLabel, font: UIFont) -> SCNText? {
    guard let name = label.name else {
        return nil
    }
    let text = SCNText()
    text.string = name
    text.font = font
    text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
    text.truncationMode = CATextLayerTruncationMode.end.rawValue
    return text
}
