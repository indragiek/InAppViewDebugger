//
//  ParallelLineView.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/7/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import Foundation

/// A view that draws one or more parallel vertical lines.
final class ParallelLineView: UIView {
    public var lineColors = [
        UIColor(red: 0.816, green: 0.008, blue: 0.106, alpha: 1.000),
        UIColor(red: 0.961, green: 0.651, blue: 0.137, alpha: 1.000),
        UIColor(red: 0.290, green: 0.565, blue: 0.886, alpha: 1.000),
        UIColor(red: 0.314, green: 0.886, blue: 0.757, alpha: 1.000),
        UIColor(red: 0.494, green: 0.827, blue: 0.129, alpha: 1.000),
        UIColor(red: 0.565, green: 0.075, blue: 0.996, alpha: 1.000),
        UIColor(red: 0.741, green: 0.063, blue: 0.878, alpha: 1.000),
        UIColor(red: 0.545, green: 0.341, blue: 0.165, alpha: 1.000)
    ]
    
    public var lineWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    public var lineSpacing: CGFloat = 12.0 {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    public var lineCount: Int = 0 {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard lineCount > 0 else {
            return
        }
        var x: CGFloat = lineSpacing
        (0..<lineCount).forEach { index in
            lineColors[index % lineColors.count].setFill()
            let rect = CGRect(x: x, y: 0.0, width: lineWidth, height: bounds.height)
            UIRectFill(rect)
            x += lineWidth + lineSpacing
        }
    }
    
    override var intrinsicContentSize: CGSize {
        guard lineCount > 0 else {
            return CGSize(width: 0.0, height: UIView.noIntrinsicMetric)
        }
        return CGSize(width: CGFloat(lineCount) * (lineWidth + lineSpacing), height: UIView.noIntrinsicMetric)
    }
}
