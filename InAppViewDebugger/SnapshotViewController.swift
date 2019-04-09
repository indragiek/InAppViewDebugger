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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.snapshotViewController(self, didFocusOnSnapshot: snapshot)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            snapshotView?.deselectAll()
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
    
    // MARK: SnapshotViewDelegate
    
    func snapshotView(_ snapshotView: SnapshotView, didSelectSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didSelectSnapshot: snapshot)
    }
    
    func snapshotView(_ snapshotView: SnapshotView, didDeselectSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didDeselectSnapshot: snapshot)
    }

    func snapshotView(_ snapshotView: SnapshotView, didFocusOnElementWithSnapshot snapshot: Snapshot) {
        snapshotView.deselectAll()
        let subViewController = SnapshotViewController(snapshot: snapshot, configuration: configuration)
        subViewController.delegate = self
        navigationController?.pushViewController(subViewController, animated: true)
    }
    
    func snapshotView(_ snapshotView: SnapshotView, showDescriptionForElement element: Element) {
        let alert = UIAlertController(title: nil, message: element.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        present(alert, animated: true, completion: nil)
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
    
    // MARK: Private
    
    func topSnapshotViewController() -> SnapshotViewController {
        if let snapshotViewController = navigationController?.topViewController as? SnapshotViewController {
            return snapshotViewController
        }
        return self
    }
}
