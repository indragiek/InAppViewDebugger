//
//  RangeSlider.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/2/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

final class RangeSlider: UIControl {
    private let trackImageView: UIImageView
    private let fillImageView: UIImageView
    private let leftHandleImageView: UIImageView
    private let rightHandleImageView: UIImageView
    
    override init(frame: CGRect) {
        trackImageView = UIImageView()
        fillImageView = UIImageView()
        leftHandleImageView = UIImageView()
        rightHandleImageView = UIImageView()
        
        super.init(frame: frame)
        
        addSubview(trackImageView)
        addSubview(fillImageView)
        addSubview(leftHandleImageView)
        addSubview(rightHandleImageView)
        
        configureTrackImageView()
        configureFillImageView()
        configureLeftHandleImageView()
        configureRightHandleImageView()
    }
    
    private func configureTrackImageView() {
        trackImageView.image = trackImage()
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackImageView.leadingAnchor.constraint(equalTo: leftHandleImageView.centerXAnchor),
            trackImageView.trailingAnchor.constraint(equalTo: rightHandleImageView.centerXAnchor)
        ])
    }
    
    private func configureFillImageView() {
        fillImageView.image = fillImage()
        fillImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fillImageView.centerYAnchor.constraint(equalTo: trackImageView.centerYAnchor),
            fillImageView.leadingAnchor.constraint(equalTo: trackImageView.leadingAnchor),
            fillImageView.trailingAnchor.constraint(equalTo: trackImageView.trailingAnchor)
        ])
    }
    
    private func configureLeftHandleImageView() {
        leftHandleImageView.image = leftHandleImage()
        leftHandleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftHandleImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2.0),
            leftHandleImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }
    
    private func configureRightHandleImageView() {
        rightHandleImageView.image = rightHandleImage()
        rightHandleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rightHandleImageView.centerYAnchor.constraint(equalTo: leftHandleImageView.centerYAnchor),
            rightHandleImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private func imageNamed(_ name: String) -> UIImage? {
    return UIImage(named: name, in: Bundle(for: RangeSlider.self), compatibleWith: nil)
}

private func trackImage() -> UIImage? {
    let insets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 4.0)
    return imageNamed("RangeSliderTrack")?.resizableImage(withCapInsets: insets)
}

private func fillImage() -> UIImage? {
    let insets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 4.0)
    return imageNamed("RangeSliderFill")?.resizableImage(withCapInsets: insets)
}

private func leftHandleImage() -> UIImage? {
    return imageNamed("RangeSliderLeftHandle")
}

private func rightHandleImage() -> UIImage? {
    return imageNamed("RangeSliderRightHandle")
}
