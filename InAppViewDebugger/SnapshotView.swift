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
    struct LayoutConstants {
        static let spacingSliderHorizontalInset: CGFloat = 10.0
    }
    
    private let configuration: SnapshotViewConfiguration
    private let snapshot: Snapshot
    private let sceneView: SCNView
    private let spacingSlider: UISlider
    private var snapshotIdentifierToNodesMap = [String: Nodes]()
    
    public init(snapshot: Snapshot, configuration: SnapshotViewConfiguration = SnapshotViewConfiguration()) {
        self.configuration = configuration
        self.snapshot = snapshot
        sceneView = SCNView()
        spacingSlider = UISlider()
        
        super.init(frame: .zero)
        
        configureSceneView()
        configureSpacingSlider()
        configureTapGestureRecognizer()
    }
    
    private func configureSceneView() {
        let scene = SCNScene()
        scene.background.contents = configuration.backgroundColor
        
        var depth = 0
        _ = snapshotNode(snapshot: snapshot,
                         parentSnapshot: nil,
                         rootNode: scene.rootNode,
                         parentSnapshotNode: nil,
                         depth: &depth,
                         snapshotIdentifierToNodesMap: &snapshotIdentifierToNodesMap,
                         configuration: configuration)
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        addSubview(sceneView)
    }
    
    private func configureSpacingSlider() {
        spacingSlider.minimumValue = configuration.minimumZSpacing
        spacingSlider.maximumValue = configuration.maximumZSpacing
        spacingSlider.isContinuous = true
        spacingSlider.addTarget(self, action: #selector(handleSpacingSliderChanged(sender:)), for: .valueChanged)
        spacingSlider.setValue(configuration.zSpacing, animated: false)
        addSubview(spacingSlider)
    }
    
    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sceneView.frame = bounds
        
        let sliderSize = spacingSlider.sizeThatFits(bounds.size)
        let safeAreaInsets = self.safeAreaInsets
        spacingSlider.frame = CGRect(
            x: safeAreaInsets.left + LayoutConstants.spacingSliderHorizontalInset,
            y: bounds.maxY - sliderSize.height - safeAreaInsets.bottom,
            width: bounds.width - (safeAreaInsets.left + safeAreaInsets.right) - (LayoutConstants.spacingSliderHorizontalInset * 2.0),
            height: sliderSize.height
        )
    }
    
    // MARK: Actions
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(ofTouch: 0, in: sceneView)
            let hitTestResult = sceneView.hitTest(point, options: nil)
            for result in hitTestResult {
                print(result.node)
            }
        }
    }
    
    @objc func handleSpacingSliderChanged(sender: UISlider) {
        let hideHeaderNodes = sender.value <= smallZOffset
        for (_, nodes) in snapshotIdentifierToNodesMap {
            if let snapshotNode = nodes.snapshotNode {
                snapshotNode.position = {
                    var position = snapshotNode.position
                    position.z = max(sender.value, smallZOffset) * Float(nodes.depth)
                    return position
                }()
            }
            if let headerNode = nodes.headerNode {
                headerNode.isHidden = hideHeaderNodes
            }
        }
    }
}

private struct Nodes {
    let snapshot: Snapshot
    let depth: Int
    
    weak var snapshotNode: SCNNode?
    weak var headerNode: SCNNode?
    weak var borderNode: SCNNode?
    
    init(snapshot: Snapshot, depth: Int) {
        self.snapshot = snapshot
        self.depth = depth
    }
}

// This value is chosen such that this offset can be applied to avoid z-fighting
// amongst nodes at the same z-position, but small enough that they appear to
// visually be on the same plane.
private let smallZOffset: Float = 0.5

private func snapshotNode(snapshot: Snapshot,
                          parentSnapshot: Snapshot?,
                          rootNode: SCNNode,
                          parentSnapshotNode: SCNNode?,
                          depth: inout Int,
                          snapshotIdentifierToNodesMap: inout [String: Nodes],
                          configuration: SnapshotViewConfiguration) -> SCNNode? {
    // Ignore elements that are not visible. These should appear in
    // the tree view, but not in the 3D view.
    if snapshot.isHidden || snapshot.frame.size == .zero {
        return nil
    }
    // Create a node whose contents are the snapshot of the element.
    let node = SCNNode(geometry: snapshotShape(snapshot: snapshot))
    node.name = snapshot.identifier
    
    var nodes = Nodes(snapshot: snapshot, depth: depth)
    nodes.snapshotNode = node
    
    // The node must be added to the root node for the coordinate
    // space calculations below to work.
    rootNode.addChildNode(node)
    node.position = {
        // Flip the y-coordinate since the SceneKit coordinate system has
        // a flipped version of the UIKit coordinate system.
        let y: CGFloat
        if let parentSnapshot = parentSnapshot {
            y = parentSnapshot.frame.height - snapshot.frame.maxY
        } else {
            y = 0.0
        }
        
        // To simplify calculating the z-axis spacing between the layers, we
        // make each snapshot node a direct child of the root rather than embedding
        // the nodes in their parent nodes in the same structure as the UI elements
        // themselves. With this flattened hierarchy, the z-position can be
        // calculated for every node simply by multiplying the spacing by the depth.
        //
        // `parentSnapshotNode` as referenced here is **not** the actual parent
        // node of `node`, it is the node **corresponding to** the parent of the
        // UI element. It is used to convert from frame coordinates, which are
        // relative to the bounds of the parent, to coordinates relative to the
        // root node.
        let positionRelativeToParent = SCNVector3(snapshot.frame.origin.x, y, 0.0)
        var positionRelativeToRoot: SCNVector3
        if let parentSnapshotNode = parentSnapshotNode {
            positionRelativeToRoot = rootNode.convertPosition(positionRelativeToParent, from: parentSnapshotNode)
        } else {
            positionRelativeToRoot = positionRelativeToParent
        }
        positionRelativeToRoot.z = Float(configuration.zSpacing) * Float(depth)
        return positionRelativeToRoot
    }()
    
    let headerAttributes: SnapshotViewConfiguration.HeaderAttributes
    switch snapshot.label.classification {
    case .normal:
        headerAttributes = configuration.normalHeaderAttributes
    case .important:
        headerAttributes = configuration.importantHeaderAttributes
    }
    
    let border = borderNode(node: node, color: headerAttributes.color)
    node.addChildNode(border)
    nodes.borderNode = border
    
    if let header = headerNode(snapshot: snapshot,
                               attributes: headerAttributes) {
        node.addChildNode(header)
        nodes.headerNode = header
        if configuration.zSpacing <= smallZOffset {
            header.isHidden = true
        }
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
        
        if let _ = snapshotNode(snapshot: child,
                                parentSnapshot: snapshot,
                                rootNode: rootNode,
                                parentSnapshotNode: node,
                                depth: &childDepth,
                                snapshotIdentifierToNodesMap: &snapshotIdentifierToNodesMap,
                                configuration: configuration) {
            maxChildDepth = max(maxChildDepth, childDepth)
            frames.append(child.frame)
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
    let topLeft = SCNVector3(min.x, max.y, smallZOffset)
    let bottomLeft = SCNVector3(min.x, min.y, smallZOffset)
    let topRight = SCNVector3(max.x, max.y, smallZOffset)
    let bottomRight = SCNVector3(max.x, min.y, smallZOffset)
    
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
    
    textNode.position = SCNVector3((Float(frame.width) / 2.0) - (textWidth / 2.0), (Float(frame.height) / 2.0) - (textHeight / 2.0), smallZOffset)
    headerNode.addChildNode(textNode)
    
    headerNode.position = SCNVector3(0.0, Float(snapshot.frame.height), smallZOffset)
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
