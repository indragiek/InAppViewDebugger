//
//  SnapshotViewController.swift
//  LiveSnapshot
//
//  Created by Indragie Karunaratne on 3/30/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

public class SnapshotViewController: UIViewController {
    private let snapshot: Snapshot
    private let configuration: SnapshotViewConfiguration
    
    public init(snapshot: Snapshot, configuration: SnapshotViewConfiguration = SnapshotViewConfiguration()) {
        self.snapshot = snapshot
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override public func loadView() {
        self.view = SnapshotView(snapshot: snapshot, configuration: configuration)
    }
}
