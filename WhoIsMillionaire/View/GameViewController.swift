//
//
//  GameViewController.swift
//  WhoIsMillionaire
//
//  Created by Pavel Reshetov on 05.02.2023.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {

    var transfer = QuestionViewController()
    var prizeAmount = ""

    // фоновое изображение
    var backgroundImageView: UIImageView  = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // круглые кнопки опций
    var fiftyFiftyButton = UIButton(type: .system)
    var hallHelpButton = UIButton(type: .system)
    var callToFriendButton = UIButton(type: .system)
    
    // кнопка стоп(лого игры)
    var stopLogoButton: UIButton = {
        let button = UIButton(type: .system)
        button.showsTouchWhenHighlighted = true
        button.setBackgroundImage(UIImage(named: "mainLogo"), for: .normal)
        button.addTarget(self, action: #selector(stopButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // таймер
    var timer = Timer()
    var totalTime = 30
    var secondPassed = 0
    
    // аудио
    var player = AVAudioPlayer() // player for sounds
    
    // лейбл таймера
    var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "30"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Roboto-Medium", size: 50)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // лейбл номера вопроса
    let questionNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Вопрос 1"
        label.textColor = .white
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.font = UIFont(name: "Roboto-Medium", size: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // лейбл суммы вопроса
    let questionSummLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textColor = .white
        label.font = UIFont(name: "Roboto-Medium", size: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // лейбл вопросов
    let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Here a place for my question!"
        label.numberOfLines = 0
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textColor = .white
        label.font = UIFont(name: "Roboto-Medium", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // кнопки ответа
    let answerButtonA = UIButton()
    let answerButtonB = UIButton()
    let answerButtonC = UIButton()
    let answerButtonD = UIButton()
    
    // экземпляр QuestionModel
    var questionModel = QuestionModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionModel.questionNumber = UserDefaults.standard.integer(forKey: "questionNumber")
        
        setupUI()
        fiftyFiftyLogic()
        hallHelpLogic()
        friendCallLogic()
        answerButtonAction()
        updateUI()
        self.navigationItem.hidesBackButton = true
        hintButtonsShow()
    }
    
    
    @objc func stopButtonPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "Выход", message: "Вы хотите закончить игру и забрать деньги?", preferredStyle: .alert)
        
        // переход на экран результата игры
        let okAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.stopTimer()
            self.stopSound()
            self.prizeAmount = self.questionModel.countOfSum()
            let resultVC = ResultViewController()
            resultVC.resultOfTheGame = self.prizeAmount
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
        // отмена выхода
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true) {
        }
    }
    
    // метод настройки кнопок опций
    func optionButtonSetup(button: UIButton) {
        button.layer.cornerRadius = 25
        button.showsTouchWhenHighlighted = true
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // метод настройки кнопок ответа
    func answerButtonSetup() {
        for button in [answerButtonA, answerButtonB, answerButtonC, answerButtonD] {
            //        button.layer.cornerRadius = 10
            //        button.showsTouchWhenHighlighted = true
            button.titleLabel?.font = .systemFont(ofSize: 16)
            //        button.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
            button.setBackgroundImage(UIImage(named: "answerButtonImage"), for: .normal)
        }
    }
    
    
    //MARK: - Таймер и музыка
    func roundTimer() {
      
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimerLabel),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func updateTimerLabel() {
    
        if timerLabel.text == "Ответ принят" {
            timer.invalidate()
            secondPassed = 40
        }
       
        if secondPassed < totalTime {
            timerLabel.text = String(totalTime)
            totalTime -= 1
        }
        
        if totalTime == 0 {
            timer.invalidate()
            gameOver()
        }
    }
    
    // метод воспр. музыки
    func playTimeSound() {
        guard let url = Bundle.main.url(forResource: "timeSound", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print ("sound error")
        }
        player.play()
    }
    
    //MARK: - UISetup
    func setupUI() {
        
        // настройка кнопок опций
        optionButtonSetup(button: stopLogoButton)
        optionButtonSetup(button: fiftyFiftyButton)
        optionButtonSetup(button: callToFriendButton)
        optionButtonSetup(button: hallHelpButton)
        
        // задаем изображения кнопкам опций
        fiftyFiftyButton.setBackgroundImage(UIImage(named: "fiftyFifty"), for: .normal)
        callToFriendButton.setBackgroundImage(UIImage(named: "friendCall"), for: .normal)
        hallHelpButton.setBackgroundImage(UIImage(named: "hallHelp"), for: .normal)
        
        // настройка кнопок ответа
        answerButtonSetup()
        
        // верхний стэк из лого-кнопки и вопроса
        let logoQuestionStackView = UIStackView(arrangedSubviews: [stopLogoButton, questionLabel])
        logoQuestionStackView.axis = .horizontal
        logoQuestionStackView.alignment = .fill
        logoQuestionStackView.spacing = 40
        logoQuestionStackView.distribution = .fill
        logoQuestionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // стэк из лейбла номера вопроса, таймера и суммы
        let questionSummStackView = UIStackView(arrangedSubviews: [questionNumberLabel, timerLabel, questionSummLabel])
        questionSummStackView.axis = .horizontal
        questionSummStackView.alignment = .center
        questionSummStackView.spacing = 30
        questionSummStackView.distribution = .equalCentering
        questionSummStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // создаем стэк из кнопок опций
        let optionStackView = UIStackView(arrangedSubviews: [fiftyFiftyButton, callToFriendButton, hallHelpButton])
        optionStackView.axis = .horizontal
        optionStackView.alignment = .fill
        optionStackView.spacing = 70
        optionStackView.distribution = .fillEqually
        optionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // создаем вертикальный стэк из кнопок выбора ответа
        let answerStackView = UIStackView(arrangedSubviews: [answerButtonA, answerButtonB, answerButtonC, answerButtonD])
        answerStackView.axis = .vertical
        answerStackView.alignment = .fill
        answerStackView.spacing = 10
        answerStackView.distribution = .fillEqually
        answerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // добавляем элементы на вью
        view.addSubview(backgroundImageView)
        view.addSubview(logoQuestionStackView)
        view.addSubview(questionSummStackView)
        view.addSubview(answerStackView)
        view.addSubview(optionStackView)
        
        // расставляем констрейнты
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
 
            logoQuestionStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            logoQuestionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            logoQuestionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            logoQuestionStackView.heightAnchor.constraint(equalToConstant: 90),
            
            questionSummStackView.topAnchor.constraint(equalTo: logoQuestionStackView.bottomAnchor, constant: 16),
            questionSummStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            questionSummStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            questionSummStackView.heightAnchor.constraint(equalToConstant: 45),
            
            answerStackView.topAnchor.constraint(equalTo: questionSummStackView.bottomAnchor, constant: 16),
            answerStackView.bottomAnchor.constraint(equalTo: optionStackView.topAnchor, constant: -80),
            answerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            answerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            optionStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            optionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            optionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            optionStackView.heightAnchor.constraint(equalToConstant: 50)
        
        ])
    }

}

