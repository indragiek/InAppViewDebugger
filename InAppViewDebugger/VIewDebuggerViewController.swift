//
//  VIewDebuggerViewController.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/4/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

/// Root view controller for the view debugger.
final class ViewDebuggerViewController: UIViewController, SnapshotViewControllerDelegate, HierarchyTableViewControllerDelegate {
    private let snapshot: Snapshot
    private let configuration: Configuration
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    private lazy var snapshotViewController: SnapshotViewController = { [unowned self] in
        let viewController = SnapshotViewController(snapshot: snapshot, configuration: configuration.snapshotViewConfiguration)
        viewController.delegate = self
        return viewController
    }()
    
    private lazy var snapshotNavigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: snapshotViewController)
        navigationController.navigationBar.isHidden = true
        return navigationController
    }()
    
    private lazy var hierarchyViewController: HierarchyTableViewController = {
        let viewController = HierarchyTableViewController(snapshot: snapshot, configuration: configuration.hierarchyViewConfiguration)
        viewController.delegate = self
        return viewController
    }()
    
    private lazy var hierarchyNavigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: hierarchyViewController)
        navigationController.navigationBar.isHidden = true
        return navigationController
    }()
    
    init(snapshot: Snapshot, configuration: Configuration = Configuration()) {
        self.snapshot = snapshot
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
        
        configureSegmentedControl()
        configureBarButtonItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectViewController(index: 0)
        addChild(pageViewController)
        
        if let pageView = pageViewController.view {
            pageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(pageView)
            NSLayoutConstraint.activate([
                pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pageView.topAnchor.constraint(equalTo: view.topAnchor),
                pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
        
        pageViewController.didMove(toParent: self)
    }
    
    // MARK: SnapshotViewControllerDelegate
    
    func snapshotViewController(_ viewController: SnapshotViewController, didSelectSnapshot snapshot: Snapshot) {
        hierarchyViewController.selectRow(forSnapshot: snapshot)
    }
    
    func snapshotViewController(_ viewController: SnapshotViewController, didDeselectSnapshot snapshot: Snapshot) {
        hierarchyViewController.deselectRow(forSnapshot: snapshot)
    }
    
    func snapshotViewController(_ viewController: SnapshotViewController, didFocusOnSnapshot snapshot: Snapshot) {
        hierarchyNavigationController.popToRootViewController(animated: false)
        hierarchyViewController.focus(snapshot: snapshot)
    }
    
    func snapshotViewControllerWillNavigateBackToPreviousSnapshot(_ viewController: SnapshotViewController) {
        hierarchyNavigationController.popViewController(animated: true)
    }
    
    // MARK: HierarchyTableViewControllerDelegate
    
    func hierarchyTableViewController(_ viewController: HierarchyTableViewController, didSelectSnapshot snapshot: Snapshot) {
        snapshotViewController.select(snapshot: snapshot)
    }
    
    func hierarchyTableViewController(_ viewController: HierarchyTableViewController, didDeselectSnapshot snapshot: Snapshot) {
        snapshotViewController.deselect(snapshot: snapshot)
    }
    
    func hierarchyTableViewController(_ viewController: HierarchyTableViewController, didFocusOnSnapshot snapshot: Snapshot) {
        snapshotViewController.focus(snapshot: snapshot)
    }
    
    func hierarchyTableViewControllerWillNavigateBackToPreviousSnapshot(_ viewController: HierarchyTableViewController) {
        snapshotNavigationController.popViewController(animated: true)
    }
    
    // MARK: Private
    
    private func configureSegmentedControl() {
        let segmentedControl = UISegmentedControl(items: [
            NSLocalizedString("Snapshot", comment: "The title for the Snapshot tab"),
            NSLocalizedString("Hierarchy", comment: "The title for the Hierarchy tab"),
            ])
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(sender:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    private func configureBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(sender:)))
    }
    
    private func selectViewController(index: Int) {
        switch index {
        case 0:
            pageViewController.setViewControllers([snapshotNavigationController], direction: .reverse, animated: false, completion: nil)
        case 1:
            pageViewController.setViewControllers([hierarchyNavigationController], direction: .forward, animated: false, completion: nil)
        default:
            fatalError("Invalid view controller index \(index)")
            break
        }
    }
    
    // MARK: Actions
    
    @objc private func segmentChanged(sender: UISegmentedControl) {
        selectViewController(index: sender.selectedSegmentIndex)
    }
    
    @objc private func done(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
