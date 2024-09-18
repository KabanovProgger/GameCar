//
//  ViewController.swift
//  GameCar
//
//  Created by Owner on 9/16/24.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var lastScoreLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage()
        
    }
    //Here we set score on Main View to it can update every game
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupScoreInLabel()
    }
    
    func setupScoreInLabel(){
        view.addSubview(lastScoreLabel)
        displayLastFiveScores()
    }
    
    func backgroundImage(){
        let background = UIImage(named: "carMainBackground.jpg")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    func displayLastFiveScores() {
        // Get last results
        let scores = UserDefaults.standard.array(forKey: "gameResults") as? [Int] ?? []
        
        // String for show results
        var resultsString = "Последние 5 игр:\n"
        
        for (index, score) in scores.enumerated() {
            resultsString += "Игра \(index + 1): \(score) очков\n"
        }
        
        // Show results on Main View
        lastScoreLabel.text = resultsString
        reloadInputViews()
    }
    
    @IBAction func startGame(_ sender: Any) {
        let gameVC = GameViewController()
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    @IBAction func showAbout(_ sender: Any) {
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
}
