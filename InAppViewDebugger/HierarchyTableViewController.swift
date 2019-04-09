//
//  HierarchyTableViewController.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/6/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

protocol HierarchyTableViewControllerDelegate: AnyObject {
    func hierarchyTableViewController(_ viewController: HierarchyTableViewController, didSelectSnapshot snapshot: Snapshot)
    func hierarchyTableViewController(_ viewController: HierarchyTableViewController, didDeselectSnapshot snapshot: Snapshot)
}

class HierarchyTableViewController: UITableViewController, HierarchyTableViewCellDelegate {
    private static let ReuseIdentifier = "HierarchyTableViewCell"
    
    private let snapshot: Snapshot
    private let configuration: HierarchyViewConfiguration
    
    private var dataSource: TreeTableViewDataSource<Snapshot>? {
        didSet {
            if isViewLoaded {
                tableView?.dataSource = dataSource
                tableView?.reloadData()
            }
        }
    }
    private var shouldIgnoreMaxDepth = false {
        didSet {
            if shouldIgnoreMaxDepth != oldValue {
                dataSource = TreeTableViewDataSource(
                    tree: snapshot,
                    maxDepth: shouldIgnoreMaxDepth ? nil : configuration.maxDepth,
                    cellFactory: cellFactory(shouldIgnoreMaxDepth: shouldIgnoreMaxDepth)
                )
            }
        }
    }
    
    weak var delegate: HierarchyTableViewControllerDelegate?
    
    init(snapshot: Snapshot, configuration: HierarchyViewConfiguration) {
        self.snapshot = snapshot
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = snapshot.element.label.name
        clearsSelectionOnViewWillAppear = false
        
        self.dataSource = TreeTableViewDataSource(
            tree: snapshot,
            maxDepth: configuration.maxDepth,
            cellFactory: cellFactory(shouldIgnoreMaxDepth: false)
        )
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
    
    // MARK: API
    
    func selectRow(forSnapshot snapshot: Snapshot) {
        shouldIgnoreMaxDepth = true
        let indexPath = dataSource?.indexPath(forValue: snapshot)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
    
    func deselectRow(forSnapshot snapshot: Snapshot) {
        shouldIgnoreMaxDepth = false
        guard let indexPath = dataSource?.indexPath(forValue: snapshot) else {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let snapshot = dataSource?.value(atIndexPath: indexPath) else {
            return
        }
        delegate?.hierarchyTableViewController(self, didSelectSnapshot: snapshot)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let snapshot = dataSource?.value(atIndexPath: indexPath) else {
            return
        }
        delegate?.hierarchyTableViewController(self, didDeselectSnapshot: snapshot)
    }
    
    // MARK: HierarchyTableViewCellDelegate
    
    func hierarchyTableViewCellDidTapSubtree(cell: HierarchyTableViewCell) {
        guard let indexPath = cell.indexPath, let snapshot = dataSource?.value(atIndexPath: indexPath) else {
            return
        }
        let subtreeViewController = HierarchyTableViewController(snapshot: snapshot, configuration: configuration)
        navigationController?.pushViewController(subtreeViewController, animated: true)
    }
    
    // MARK: Private
    
    private func cellFactory(shouldIgnoreMaxDepth: Bool) -> TreeTableViewDataSource<Snapshot>.CellFactory {
        return { [unowned self] (tableView, value, depth, indexPath, isCollapsed) in
            let reuseIdentifier = HierarchyTableViewController.ReuseIdentifier
            let cell = (tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? HierarchyTableViewCell) ?? HierarchyTableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            
            let baseFont = self.configuration.nameFont
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
            cell.frameLabel.font = self.configuration.frameFont
            cell.frameLabel.text = String(format: "(%.1f, %.1f, %.1f, %.1f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
            cell.lineView.lineCount = depth
            cell.lineView.lineColors = self.configuration.lineColors
            cell.lineView.lineWidth = self.configuration.lineWidth
            cell.lineView.lineSpacing = self.configuration.lineSpacing
            cell.showSubtreeButton = !shouldIgnoreMaxDepth && !value.children.isEmpty && depth >= (self.configuration.maxDepth ?? Int.max)
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        }
    }
}

extension Snapshot: Tree {}
