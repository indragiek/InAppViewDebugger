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
    public var lineColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var lineWidth: CGFloat = 0.5 {
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
        lineColor.setFill()
        (1...lineCount).forEach { _ in
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
