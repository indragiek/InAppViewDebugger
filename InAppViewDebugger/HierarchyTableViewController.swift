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
            let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? HierarchyTableViewCell) ?? HierarchyTableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
            cell.textLabel?.text = value.label.name
            cell.detailTextLabel?.text = "\(value.frame)"
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
        tableView.reloadData()
    }
}
