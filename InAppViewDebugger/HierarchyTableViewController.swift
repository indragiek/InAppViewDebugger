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
    
    init(snapshot: Snapshot) {
        self.snapshot = snapshot
        self.dataSource = TreeTableViewDataSource(tree: snapshot) { (tableView, value, depth, isCollapsed) in
            let reuseIdentifier = HierarchyTableViewController.ReuseIdentifier
            let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? HierarchyTableViewCell) ?? HierarchyTableViewCell(reuseIdentifier: reuseIdentifier)
            cell.nameLabel.text = value.label.name
            let frame = value.frame
            cell.frameLabel.text = String(format: "(%.1f, %.1f, %.1f, %.1f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
            cell.depth = depth
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
