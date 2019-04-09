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
    
    let lineView: ParallelLineView = {
        let lineView = ParallelLineView()
        lineView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        return lineView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let frameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtreeButton: UIButton = {
        let button = UIButton(type: .custom)
        let color = UIColor(white: 0.0, alpha: 0.25)
        button.setTitle(NSLocalizedString("Subtree", comment: "Show the subtree starting at this element"), for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        let disclosureImage = UIImage(named: "DisclosureIndicator", in: Bundle(for: HierarchyTableViewCell.self), compatibleWith: nil)
        button.setImage(disclosureImage, for: .normal)
        button.layer.cornerRadius = 4.0
        button.layer.borderWidth = 1.5
        button.layer.borderColor = color.cgColor
        
        let imageTextSpacing: CGFloat = 4.0
        let imageTextInset = imageTextSpacing / 2.0
        button.imageEdgeInsets = UIEdgeInsets(top: 1.0, left: imageTextInset, bottom: 0, right: -imageTextInset)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageTextInset, bottom: 0.0, right: imageTextInset)
        button.contentEdgeInsets = UIEdgeInsets(top: 4.0, left:
            4.0 + imageTextInset, bottom: 4.0, right: 4.0 + imageTextInset)
        button.semanticContentAttribute = .forceRightToLeft
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return button
    }()
    
    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lineView)
        contentView.addSubview(labelStackView)
        contentView.addSubview(subtreeButton)
        
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(frameLabel)

        let marginsGuide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: marginsGuide.leadingAnchor),
            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 5.0),
            labelStackView.centerYAnchor.constraint(equalTo: marginsGuide.centerYAnchor),
            subtreeButton.leadingAnchor.constraint(equalTo: labelStackView.trailingAnchor, constant: 5.0),
            subtreeButton.centerYAnchor.constraint(equalTo: marginsGuide.centerYAnchor),
            subtreeButton.trailingAnchor.constraint(equalTo: marginsGuide.trailingAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
