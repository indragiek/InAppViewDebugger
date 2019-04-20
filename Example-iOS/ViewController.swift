//
//  ViewController.swift
//  LiveSnapshot
//
//  Created by Indragie Karunaratne on 3/30/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit
import SceneKit
import InAppViewDebugger

class ViewController: UIViewController {
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.cyan
        view.frame = UIScreen.main.bounds
        view.restorationIdentifier = "root"
        
        let frames = view.bounds.divided(atDistance: view.bounds.width / 2, from: .minXEdge)
        let view1 = UIView()
        view1.backgroundColor = .yellow
        view1.frame = frames.slice
        view1.restorationIdentifier = "left half"
        
        let view2 = UIView()
        view2.backgroundColor = .purple
        view2.frame = frames.remainder
        view2.restorationIdentifier = "right half"
        
        view.addSubview(view1)
        view.addSubview(view2)
        
        let frames1 = view1.bounds.divided(atDistance: view1.bounds.height / 2, from: .minYEdge)
        let view3 = UIView()
        view3.backgroundColor = .blue
        view3.frame = frames1.slice.insetBy(dx: 0, dy: -10)
        view3.restorationIdentifier = "3"
        
        let v = UIView()
        v.backgroundColor = .brown
        v.frame = view3.bounds.insetBy(dx: 20, dy: 20)
        view3.addSubview(v)
        
        let view4 = UIView()
        view4.backgroundColor = .orange
        view4.frame = frames1.remainder
        view4.restorationIdentifier = "4"
        
        view1.addSubview(view3)
        view1.addSubview(view4)
        
        let frames2 = view2.bounds.divided(atDistance: view2.bounds.height / 2, from: .minYEdge)
        let view5 = UIView()
        view5.backgroundColor = .red
        view5.frame = frames2.slice
        view5.restorationIdentifier = "5"
        
        let view6 = UIView()
        view6.backgroundColor = .green
        view6.frame = frames2.remainder
        view6.restorationIdentifier = "6"
        
        view2.addSubview(view5)
        view2.addSubview(view6)
        
        self.view = view
    }
    
    @IBAction func snapshot(sender: UIBarButtonItem) {
        InAppViewDebugger.presentViewDebugger()
    }
}

