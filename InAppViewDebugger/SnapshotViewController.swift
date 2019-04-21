//
//  SnapshotViewController.swift
//  LiveSnapshot
//
//  Created by Indragie Karunaratne on 3/30/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

protocol SnapshotViewControllerDelegate: AnyObject {
    func snapshotViewController(_ viewController: SnapshotViewController, didSelectSnapshot snapshot: Snapshot)
    func snapshotViewController(_ viewController: SnapshotViewController, didDeselectSnapshot snapshot: Snapshot)
    func snapshotViewController(_ viewController: SnapshotViewController, didFocusOnSnapshot snapshot: Snapshot)
    func snapshotViewControllerWillNavigateBackToPreviousSnapshot(_ viewController: SnapshotViewController)
}

/// View controller that renders a 3D snapshot view using SceneKit.
final class SnapshotViewController: UIViewController, SnapshotViewDelegate, SnapshotViewControllerDelegate {
    private let snapshot: Snapshot
    private let configuration: SnapshotViewConfiguration
    
    private var snapshotView: SnapshotView?
    weak var delegate: SnapshotViewControllerDelegate?
    
    init(snapshot: Snapshot, configuration: SnapshotViewConfiguration = SnapshotViewConfiguration()) {
        self.snapshot = snapshot
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = snapshot.element.label.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func loadView() {
        let snapshotView = SnapshotView(snapshot: snapshot, configuration: configuration)
        snapshotView.delegate = self
        self.snapshotView = snapshotView
        self.view = snapshotView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            snapshotView?.deselectAll()
            delegate?.snapshotViewControllerWillNavigateBackToPreviousSnapshot(self)
        }
    }
    
    // MARK: API
    
    func select(snapshot: Snapshot) {
        let topViewController = topSnapshotViewController()
        if topViewController == self {
            snapshotView?.select(snapshot: snapshot)
        } else {
            topViewController.select(snapshot: snapshot)
        }
    }
    
    func deselect(snapshot: Snapshot) {
        let topViewController = topSnapshotViewController()
        if topViewController == self {
            snapshotView?.deselect(snapshot: snapshot)
        } else {
            topViewController.deselect(snapshot: snapshot)
        }
    }
    
    func focus(snapshot: Snapshot) {
        focus(snapshot: snapshot, callDelegate: false)
    }
    
    // MARK: SnapshotViewDelegate
    
    func snapshotView(_ snapshotView: SnapshotView, didSelectSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didSelectSnapshot: snapshot)
    }
    
    func snapshotView(_ snapshotView: SnapshotView, didDeselectSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didDeselectSnapshot: snapshot)
    }

    func snapshotView(_ snapshotView: SnapshotView, didLongPressSnapshot snapshot: Snapshot, point: CGPoint) {
        let actionSheet = makeActionSheet(snapshot: snapshot, sourceView: snapshotView, sourcePoint: point) { snapshot in
            self.focus(snapshot: snapshot, callDelegate: true)
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    func snapshotView(_ snapshotView: SnapshotView, showAlertController alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
    }

    // MARK: SnapshotViewControllerDelegate
    
    func snapshotViewController(_ viewController: SnapshotViewController, didSelectSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didSelectSnapshot: snapshot)
    }
    
    func snapshotViewController(_ viewController: SnapshotViewController, didDeselectSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didDeselectSnapshot: snapshot)
    }
    
    func snapshotViewController(_ viewController: SnapshotViewController, didFocusOnSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didFocusOnSnapshot: snapshot)
    }
    
    func snapshotViewControllerWillNavigateBackToPreviousSnapshot(_ viewController: SnapshotViewController) {
        delegate?.snapshotViewControllerWillNavigateBackToPreviousSnapshot(self)
    }
    
    // MARK: Private
    
    private func focus(snapshot: Snapshot, callDelegate: Bool) {
        let topViewController = topSnapshotViewController()
        if topViewController == self {
            snapshotView?.deselectAll()
            let subtreeViewController = SnapshotViewController(snapshot: snapshot, configuration: configuration)
            subtreeViewController.delegate = self
            navigationController?.pushViewController(subtreeViewController, animated: true)
            if callDelegate {
                delegate?.snapshotViewController(self, didFocusOnSnapshot: snapshot)
            }
        } else {
            topViewController.focus(snapshot: snapshot)
        }
    }
    
    private func topSnapshotViewController() -> SnapshotViewController {
        if let snapshotViewController = navigationController?.topViewController as? SnapshotViewController {
            return snapshotViewController
        }
        return self
    }
}
