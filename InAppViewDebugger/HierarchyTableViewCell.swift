//
//  HierarchyTableViewCell.swift
//  InAppViewDebugger
//
//  Created by Indragie Karunaratne on 4/6/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

import UIKit

final class HierarchyTableViewCell: UITableViewCell {
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 3.0
        stackView.axis = .vertical
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let lineView: ParallelLineView = {
        let lineView = ParallelLineView()
        lineView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        return lineView
    }()
    
    let nameLabel = UILabel()
    let frameLabel = UILabel()
    
    public var depth: Int = 0 {
        didSet {
            lineView.lineCount = depth
        }
    }
    
    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lineView)
        contentView.addSubview(labelStackView)
        
        configureNameLabel()
        configureFrameLabel()
        configureConstraints()
    }
    
    private func configureNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .preferredFont(forTextStyle: .body)
        labelStackView.addArrangedSubview(nameLabel)
    }
    
    private func configureFrameLabel() {
        frameLabel.translatesAutoresizingMaskIntoConstraints = false
        frameLabel.font = .preferredFont(forTextStyle: .caption1)
        labelStackView.addArrangedSubview(frameLabel)
    }
    
    private func configureConstraints() {
        let marginsGuide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: marginsGuide.leadingAnchor),
            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 5.0),
            labelStackView.trailingAnchor.constraint(equalTo: marginsGuide.trailingAnchor),
            labelStackView.centerYAnchor.constraint(equalTo: marginsGuide.centerYAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
