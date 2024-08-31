//
//  ToDoTableviewCell.swift
//  ToDo
//
//  Created by Sergey Marsalov on 31.08.2024.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {
    private let circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let toDoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let toDoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    private var toDoItem: ToDoItem?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateCircleAppearance()
    }
    
    func configure(toDo: ToDoItem) {
        self.toDoItem = toDo
        
        toDoLabel.text = toDo.toDo
        toDoDescriptionLabel.text = toDo.toDoDescription
        dateLabel.text = DateFormatter.localizedString(from: toDo.date!, dateStyle: .short, timeStyle: .none)
        
        
        updateCircleAppearance()
    }
    
    private func updateCircleAppearance() {
        guard let toDo = toDoItem else { return }
        
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let circleColor: UIColor = isDarkMode ? .white : .black
        
        if toDo.isCompleted {
            
            circleView.backgroundColor = circleColor
            circleView.layer.borderWidth = 0
        } else {
            circleView.backgroundColor = .clear
            circleView.layer.borderWidth = 2
            circleView.layer.borderColor = circleColor.cgColor
        }
    }
    
    private func setupCell() {
        contentView.addSubview(circleView)
        contentView.addSubview(toDoLabel)
        contentView.addSubview(toDoDescriptionLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 24),
            circleView.heightAnchor.constraint(equalToConstant: 24),
            
            toDoLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 15),
            toDoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            toDoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            toDoDescriptionLabel.leadingAnchor.constraint(equalTo: toDoLabel.leadingAnchor),
            toDoDescriptionLabel.topAnchor.constraint(equalTo: toDoLabel.bottomAnchor, constant: 5),
            toDoDescriptionLabel.trailingAnchor.constraint(equalTo: toDoLabel.trailingAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: toDoLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: toDoDescriptionLabel.bottomAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: toDoLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
