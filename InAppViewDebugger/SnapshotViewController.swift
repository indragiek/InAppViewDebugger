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
}

/// View controller that renders a 3D snapshot view using SceneKit.
final class SnapshotViewController: UIViewController, SnapshotViewDelegate {
    private let snapshot: Snapshot
    private let configuration: SnapshotViewConfiguration
    
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
        self.view = snapshotView
    }
    
    // MARK: SnapshotViewDelegate
    
    func snapshotView(_ snapshotView: SnapshotView, didSelectSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didSelectSnapshot: snapshot)
    }
    
    func snapshotView(_ snapshotView: SnapshotView, didDeselectSnapshot snapshot: Snapshot) {
        delegate?.snapshotViewController(self, didDeselectSnapshot: snapshot)
    }

    func snapshotView(_ snapshotView: SnapshotView, didFocusOnElementWithSnapshot snapshot: Snapshot) {
        let childSnapshotVC = SnapshotViewController(snapshot: snapshot, configuration: configuration)
        navigationController?.pushViewController(childSnapshotVC, animated: true)
    }
    
    func snapshotView(_ snapshotView: SnapshotView, showDescriptionForElement element: Element) {
        let alert = UIAlertController(title: nil, message: element.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        present(alert, animated: true, completion: nil)
    }
}
