//
//  GameViewController.swift
//  GameCar
//
//  Created by Owner on 9/16/24.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    
    var carView: UIImageView!
    var gameTimer: Timer?
    var obstacleTimer: Timer?
    var bonusTimer: Timer?
    var slowBonusTimer: Timer?
    var speedIncreaseTimer: Timer?
    var moveTimer: Timer?
    var isMovingLeft = false
    var isMovingRight = false
    var obstacles: [UIView] = []
    var bonuses: [UIImageView] = []
    var slowBonuses: [UIImageView] = []
    var isGamePaused = false
    var initialSpeed: CGFloat = 5
    var currentSpeed: CGFloat = 5
    var speedIncreaseRate: CGFloat = 0.5 // add speed every 10 sec
    var scoreLabel: UILabel!
    var backgroundMusicPlayer: AVAudioPlayer?
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Очки: \(score)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundMusic()
        backgroundImage()
        setupGameUI()
        startGameLoop()
    }
    
    private func setupBackgroundMusic() {
        guard let musicURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else {
            print("Не удалось найти файл музыки")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
            backgroundMusicPlayer?.numberOfLoops = -1 // cycle music
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            print("Не удалось воспроизвести музыку: \(error.localizedDescription)")
        }
    }
    
    private func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    private func backgroundImage(){
        let background = UIImage(named: "roadBackground.jpg")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    private func setupGameUI() {
        // add car on View
        carView = UIImageView(image: UIImage(named: "car.png"))
        carView.frame = CGRect(x: view.frame.width / 2 - 25, y: view.frame.height - 120, width: 50, height: 100)
        view.addSubview(carView)
        
        // add panel of buttons
        let leftButton = UIButton(type: .system)
        leftButton.setImage(UIImage(systemName: "arrow.left.circle.fill"), for:.normal)
        leftButton.addTarget(self, action: #selector(startMovingLeft), for: .touchDown) // Начало движения
        leftButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchUpOutside]) // Остановка при отпускании
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftButton)
        
        
        let rightButton = UIButton(type: .system)
        rightButton.setImage(UIImage(systemName: "arrow.right.circle.fill"), for:.normal)
        rightButton.addTarget(self, action: #selector(startMovingRight), for: .touchDown) // Начало движения
        rightButton.addTarget(self, action: #selector(stopMoving), for: [.touchUpInside, .touchUpOutside]) // Остановка при отпускании
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightButton)
        
        let pauseButton = UIButton(type: .system)
        pauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for:.normal)
        pauseButton.addTarget(self, action: #selector(togglePause), for: .touchUpInside)
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pauseButton)
        
        // constraints for buttons
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            leftButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            
            rightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
            rightButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pauseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
        ])
        
        // add label for score
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .white
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
    }
    
    @objc private func startMovingLeft() {
        isMovingLeft = true
        moveTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(moveCar), userInfo: nil, repeats: true)
    }
    
    @objc private func startMovingRight() {
        isMovingRight = true
        moveTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(moveCar), userInfo: nil, repeats: true)
    }
    
    @objc private func stopMoving() {
        isMovingLeft = false
        isMovingRight = false
        moveTimer?.invalidate()
    }
    
    @objc private func moveCar() {
        if isMovingLeft && carView.frame.origin.x > 0 {
            carView.frame.origin.x -= 5
        }
        if isMovingRight && carView.frame.origin.x + carView.frame.width < view.frame.width {
            carView.frame.origin.x += 5
        }
    }
    
    @objc private func togglePause() {
        isGamePaused.toggle()
        if isGamePaused {
            gameTimer?.invalidate()
            obstacleTimer?.invalidate()
            bonusTimer?.invalidate()
            slowBonusTimer?.invalidate()
            speedIncreaseTimer?.invalidate()
        } else {
            startGameLoop()
        }
    }
    
    private func startGameLoop() {
        gameTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        obstacleTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(createObstacle), userInfo: nil, repeats: true)
        
        bonusTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(createBonus), userInfo: nil, repeats: true)
        
        slowBonusTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(createSlowBonus), userInfo: nil, repeats: true)
        
        // timer for add speed for every 10 sec
        speedIncreaseTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(increaseSpeed), userInfo: nil, repeats: true)
    }
    
    @objc private func updateGame() {
        if isGamePaused { return }
        
        // move obstacles down
        for obstacle in obstacles {
            obstacle.frame.origin.y += currentSpeed
            if obstacle.frame.intersects(carView.frame) {
                gameOver()
            }
        }
        
        // delete obstacles which not on frame of view
        obstacles.removeAll { obstacle in
            if obstacle.frame.origin.y > view.frame.height {
                obstacle.removeFromSuperview()
                return true
            }
            return false
        }
        
        // move bonuses down
        for bonus in bonuses {
            bonus.frame.origin.y += currentSpeed
            // if car get bonus
            if bonus.frame.intersects(carView.frame) {
                bonus.removeFromSuperview()
                score += 10 // add 10 for score
            }
        }
        
        // delete bonuses which not on frame of view
        bonuses.removeAll { bonus in
            if bonus.frame.origin.y > view.frame.height {
                bonus.removeFromSuperview()
                return true
            }
            return false
        }
        
        // move ice (slow) bonuses down
        for slowBonus in slowBonuses {
            slowBonus.frame.origin.y += currentSpeed
            // Якщо машинка збирає замедляючий бонус
            if slowBonus.frame.intersects(carView.frame) {
                slowBonus.removeFromSuperview()
                applySlowBonus()
            }
        }
        
        // delete bonuses which not on frame of view
        slowBonuses.removeAll { slowBonus in
            if slowBonus.frame.origin.y > view.frame.height {
                slowBonus.removeFromSuperview()
                return true
            }
            return false
        }
    }
    
    @objc private func createObstacle() {
        
        let obstacleImageView = UIImageView(image: UIImage(named: "obstacleCar.png"))//
        obstacleImageView.frame = CGRect(x: CGFloat.random(in: 0...view.frame.width - 50), y: -100, width: 50, height: 100)
        view.addSubview(obstacleImageView)
        obstacles.append(obstacleImageView)
    }
    
    @objc private func createBonus() {
        let bonusImageView = UIImageView(image: UIImage(named: "coin.png")) // Бонус як картинка монети
        bonusImageView.frame = CGRect(x: CGFloat.random(in: 0...view.frame.width - 30), y: -50, width: 50, height: 50)
        view.addSubview(bonusImageView)
        bonuses.append(bonusImageView)
    }
    
    @objc private func createSlowBonus() {
        let slowBonusImageView = UIImageView(image: UIImage(named: "ice.png")) // Бонус як картинка льоду
        slowBonusImageView.frame = CGRect(x: CGFloat.random(in: 0...view.frame.width - 30), y: -50, width: 50, height: 50)
        view.addSubview(slowBonusImageView)
        slowBonuses.append(slowBonusImageView)
    }
    
    @objc private func increaseSpeed() {
        currentSpeed += speedIncreaseRate
    }
    
    private func applySlowBonus() {
        currentSpeed = initialSpeed / 2 // Замедляем игру
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.currentSpeed = self?.initialSpeed ?? 5 // Восстанавливаем скорость через 2 секунды
        }
    }
    
    // Get score
    func saveScore(_ score: Int){
        var scores = UserDefaults.standard.array(forKey: "gameResults") as? [Int] ?? []
        
        // add new score
        scores.append(score)
        
        // last 5 results
        if scores.count > 5 {
            scores.removeFirst()
        }
        
        // save results in UserDefaults
        UserDefaults.standard.set(scores, forKey: "gameResults")
        
    }
    private func gameOver() {
        gameTimer?.invalidate()
        obstacleTimer?.invalidate()
        bonusTimer?.invalidate()
        slowBonusTimer?.invalidate()
        speedIncreaseTimer?.invalidate()
        stopBackgroundMusic() //
        saveScore(score)
        
        let alert = UIAlertController(title: "Гра закінчена", message: "Ви програли!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
}



