//
//  HierarchyTableViewController.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/6/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

extension Snapshot: Tree {}

class HierarchyTableViewController: UITableViewController, HierarchyTableViewCellDelegate {
    private static let ReuseIdentifier = "HierarchyTableViewCell"
    
    private let snapshot: Snapshot
    private let configuration: HierarchyViewConfiguration
    private var dataSource: TreeTableViewDataSource<Snapshot>?
    
    init(snapshot: Snapshot, configuration: HierarchyViewConfiguration) {
        self.snapshot = snapshot
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = snapshot.element.label.name
        
        self.dataSource = TreeTableViewDataSource(tree: snapshot, maxDepth: configuration.maxDepth) { [weak self] (tableView, value, depth, indexPath, isCollapsed) in
            let reuseIdentifier = HierarchyTableViewController.ReuseIdentifier
            let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? HierarchyTableViewCell) ?? HierarchyTableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            
            let baseFont = configuration.nameFont
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
            cell.frameLabel.font = configuration.frameFont
            cell.frameLabel.text = String(format: "(%.1f, %.1f, %.1f, %.1f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
            cell.lineView.lineCount = depth
            cell.lineView.lineColors = configuration.lineColors
            cell.lineView.lineWidth = configuration.lineWidth
            cell.lineView.lineSpacing = configuration.lineSpacing
            cell.subtreeButton.isHidden = value.children.isEmpty || depth < (configuration.maxDepth ?? Int.max)
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(HierarchyTableViewCell.self, forCellReuseIdentifier: HierarchyTableViewController.ReuseIdentifier)
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
    }
    
    // MARK: HierarchyTableViewCellDelegate
    
    func hierarchyTableViewCellDidTapSubtree(cell: HierarchyTableViewCell) {
        guard let indexPath = cell.indexPath, let snapshot = dataSource?.value(atIndexPath: indexPath) else {
            return
        }
        let subtreeViewController = HierarchyTableViewController(snapshot: snapshot, configuration: configuration)
        navigationController?.pushViewController(subtreeViewController, animated: true)
    }
}
