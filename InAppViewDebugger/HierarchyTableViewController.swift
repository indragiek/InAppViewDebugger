//
//  HierarchyTableViewController.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/6/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

extension Snapshot: Tree {}

class HierarchyTableViewController: UITableViewController {
    private static let ReuseIdentifier = "HierarchyTableViewCell"
    
    private let snapshot: Snapshot
    private let dataSource: TreeTableViewDataSource<Snapshot>
    
    init(snapshot: Snapshot, configuration: HierarchyViewConfiguration) {
        self.snapshot = snapshot
        self.dataSource = TreeTableViewDataSource(tree: snapshot, maxDepth: configuration.maxDepth) { (tableView, value, depth, isCollapsed) in
            let reuseIdentifier = HierarchyTableViewController.ReuseIdentifier
            let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? HierarchyTableViewCell) ?? HierarchyTableViewCell(reuseIdentifier: reuseIdentifier)
            
            let baseFont = UIFont.preferredFont(forTextStyle: .body)
            switch value.label.classification {
            case .normal:
                cell.nameLabel.font = baseFont
            case .important:
                if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) {
                    cell.nameLabel.font = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                } else {
                    cell.nameLabel.font = baseFont
                }
            }
            cell.nameLabel.text = value.label.name
            
            let frame = value.frame
            cell.frameLabel.text = String(format: "(%.1f, %.1f, %.1f, %.1f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
            cell.lineView.lineCount = depth
            cell.lineView.lineColors = configuration.lineColors
            cell.lineView.lineWidth = configuration.lineWidth
            cell.lineView.lineSpacing = configuration.lineSpacing
            cell.subtreeButton.isHidden = depth < (configuration.maxDepth ?? Int.max)
            return cell
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.reloadData()
    }
}
