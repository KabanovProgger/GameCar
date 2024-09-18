//
//  AboutViewController.swift
//  GameCar
//
//  Created by Owner on 9/16/24.
//

import UIKit

class AboutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage()
        setupUI()
    }
    
    private func setupUI() {
        let aboutLabel = UILabel()
        aboutLabel.text = "Це гра, де ви керуєте авто, збираєте бонуси і ухиляєтесь від перешкод."
        aboutLabel.textColor = .white
        aboutLabel.numberOfLines = 0
        aboutLabel.textAlignment = .center
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aboutLabel)
        
        NSLayoutConstraint.activate([
            aboutLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aboutLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            aboutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            aboutLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func backgroundImage(){
        let background = UIImage(named: "carbackground.jpg")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}
