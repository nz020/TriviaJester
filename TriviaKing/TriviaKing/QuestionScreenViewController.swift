//
//  QuestionScreenViewController.swift
//  TriviaKing
//
//  Created by Nikita Zaripov on 19.12.21.
//

import UIKit

class QuestionScreenViewController: UIViewController {
    
    @IBOutlet weak var boxAnwer1: UIImageView!
    @IBOutlet weak var boxCorrectAnswer1: UIImageView!
    @IBOutlet weak var boxWrongAnswer1: UIImageView!
    @IBOutlet weak var boxAnswer2: UIImageView!
    @IBOutlet weak var boxCorrectAnswer2: UIImageView!
    @IBOutlet weak var boxWrongAnswer2: UIImageView!
    @IBOutlet weak var boxAnswer3: UIImageView!
    @IBOutlet weak var boxWrongAnswer3: UIImageView!
    @IBOutlet weak var boxCorrectAnswer3: UIImageView!
    @IBOutlet weak var boxAnswer4: UIImageView!
    @IBOutlet weak var boxCorrectAnswer4: UIImageView!
    @IBOutlet weak var boxWrongAnswer4: UIImageView!
    
    @IBOutlet weak var feedBackLabel: UILabel!
    @IBOutlet weak var numberofLivesLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var firstAnswer: UIButton!
    @IBOutlet weak var secondAnswer: UIButton!
    @IBOutlet weak var thirdAnswer: UIButton!
    @IBOutlet weak var fourthAnswer: UIButton!
    var overlay : UIView?
    let font = UIFont(name: "Hey Comic", size: 18)


    let apiInstance = OTDBAPIController.INSTANCE
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var database: LocalStorageController?
    var selectedCategory: String? 
    
    var isAnswerCorrect: Bool = false;
    var numberOfLives: Int = 3
    var streak: Int = 0
    var correctAnswers: Int = 0
    var questions: [Question] = [Question]()
    var correctIndex: Int?
    
    var secondsBeforeNextQuestion: Int = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideBoxes()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        database = LocalStorageController(delegate: appDelegate)
        numberofLivesLabel.text = "\(numberOfLives)"
        streakLabel.text = "\(streak)"
        
        print("Selected Category:", selectedCategory ?? "")
        
        //Overlay + loadingIndicator before Data is loaded
        
        overlay = UIView(frame: view.frame)
        overlay!.backgroundColor = UIColor.white
        overlay!.alpha = 1
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(
                                                        x: UIScreen.main.bounds.size.width*0.5,
                                                        y: UIScreen.main.bounds.size.height*0.5,
                                                        width: 50,
                                                        height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        overlay?.addSubview(loadingIndicator)
        view.addSubview(overlay!)

        //API Call
        getQuestion()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print(OTDBAPIController.catDict.someKey(forValue: selectedCategory!)!)
        database?.saveCategory(category: OTDBAPIController.catDict.someKey(forValue: selectedCategory!)!, correctAnswers: correctAnswers, wrongAnswers: (-1 * (numberOfLives-3)), streak: streak)
    }
    
    func getQuestion() {
        apiInstance.getQuestion(category: selectedCategory ?? "") { result in
            
            if(result?.count == 0) {
                //Since no question got retrieved either there was an error loading the data or the player has played through all questions in the respective category. -> Throw him to the main screen.
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
            
            DispatchQueue.main.async {
                self.questions = result!
                self.updateView()
            }
            
        }
    }
    
    func updateView() {
        feedBackLabel.isHidden = true
        questionLabel.text = questions[0].question.removingPercentEncoding
        difficultyLabel.text = questions[0].difficulty.removingPercentEncoding?.firstUppercased
        randomizePositionOfCorrectAnswer(correctAnswer: questions[0].correct_answer, wrongAnswers: questions[0].incorrect_answers)
        self.title = "\(OTDBAPIController.catDict.someKey(forValue: selectedCategory ?? "0") ?? "Default Category")"
        overlay?.removeFromSuperview()
        switch questions[0].difficulty {
        case "easy":
            pointsLabel.text = "+1"
        case "medium":
            pointsLabel.text = "+2"
        case "hard":
            pointsLabel.text = "+3"
        default:
            pointsLabel.text = "+1"
        }
    }
    
    func randomizePositionOfCorrectAnswer(correctAnswer: String, wrongAnswers: [String]) {
        
        var answersArray: [String] = [correctAnswer] + wrongAnswers;
        answersArray.shuffle()
        
        correctIndex = (answersArray.firstIndex(of: correctAnswer) ?? 0) + 1
        
        self.firstAnswer.setTitle(answersArray[0].removingPercentEncoding, for: .normal)
        self.firstAnswer.setAttributedTitle(NSAttributedString(string: answersArray[0].removingPercentEncoding!, attributes: [NSAttributedString.Key.font: font!]), for: .normal)
        self.secondAnswer.setTitle(answersArray[1].removingPercentEncoding, for: .normal)
        self.secondAnswer.setAttributedTitle(NSAttributedString(string: answersArray[1].removingPercentEncoding!, attributes: [NSAttributedString.Key.font: font!]), for: .normal)
        self.thirdAnswer.setTitle(answersArray[2].removingPercentEncoding, for: .normal)

        self.thirdAnswer.setAttributedTitle(NSAttributedString(string: answersArray[2].removingPercentEncoding!, attributes: [NSAttributedString.Key.font: font!]), for: .normal)
        self.fourthAnswer.setTitle(answersArray[3].removingPercentEncoding, for: .normal)
        self.fourthAnswer.setAttributedTitle(NSAttributedString(string: answersArray[3].removingPercentEncoding!, attributes: [NSAttributedString.Key.font: font!]), for: .normal)
        
        
    }
    
    @IBAction func firstAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = "\(sender.title(for: .normal) ?? "")"
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        showCorrectBoxes(answerNumber: correctIndex ?? 0)

        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onTimerEnd), userInfo: nil, repeats: false)
        disableButtons()
        //getQuestion()
    }
    
    @IBAction func secondAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = "\(sender.title(for: .normal) ?? "")"
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        showCorrectBoxes(answerNumber: correctIndex ?? 0)

        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onTimerEnd), userInfo: nil, repeats: false)
        disableButtons()
        //getQuestion()
    }
    
    @IBAction func thirdAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = "\(sender.title(for: .normal) ?? "")"
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        showCorrectBoxes(answerNumber: correctIndex ?? 0)

        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onTimerEnd), userInfo: nil, repeats: false)
        disableButtons()
        //getQuestion()
    }
    
    @IBAction func fourthAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = "\(sender.title(for: .normal) ?? "")"
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        showCorrectBoxes(answerNumber: correctIndex ?? 0)

        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onTimerEnd), userInfo: nil, repeats: false)
        disableButtons()
        //getQuestion()
    }
    
    func checkCorrectAnswer (givenAnswer: String) {
        let correctAnswer = questions[0].correct_answer.removingPercentEncoding ?? ""
        let clicked = givenAnswer.removingPercentEncoding ?? ""
        print(correctAnswer)
        
        print(clicked)
        
        if (clicked==correctAnswer) {
            isAnswerCorrect = true
            feedBackLabel.text = "DING DONG"
            feedBackLabel.textColor = UIColor.green
            correctAnswers += 1
            switch questions[0].difficulty {
            case "easy":
                streak += 1
            case "medium":
                streak += 2
            case "hard":
                streak += 3
            default:
                streak += 1
            }
            streakLabel.text = "\(streak)"
            print("Correct")
        }
        else {
            print("Wrong")
            isAnswerCorrect = false
            screenShake()
            feedBackLabel.text = "SO BAD XD"
            feedBackLabel.textColor = UIColor.red
            numberOfLives -= 1
            numberofLivesLabel.text = "\(numberOfLives)"
            checkGameOver()
        }
        feedBackLabel.isHidden = false
    }
    
    func showCorrectBoxes (answerNumber: Int) {
        switch answerNumber {
        case 1:
            boxCorrectAnswer1.isHidden = false
            boxWrongAnswer2.isHidden = false
            boxWrongAnswer3.isHidden = false
            boxWrongAnswer4.isHidden = false
        case 2:
            boxWrongAnswer1.isHidden = false
            boxCorrectAnswer2.isHidden = false
            boxWrongAnswer3.isHidden = false
            boxWrongAnswer4.isHidden = false
        case 3:
            boxWrongAnswer1.isHidden = false
            boxWrongAnswer2.isHidden = false
            boxCorrectAnswer3.isHidden = false
            boxWrongAnswer4.isHidden = false
        case 4:
            boxWrongAnswer1.isHidden = false
            boxWrongAnswer2.isHidden = false
            boxWrongAnswer3.isHidden = false
            boxCorrectAnswer4.isHidden = false
        default:
            print("Could not show correct answers...")
        }
    }
    
    func checkGameOver () {
        if (numberOfLives < 1) {
            print("Game Over")
            let alert = UIAlertController(title: "Game Over", message: "You scored \(streak) Points", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK :(", style: .default, handler: {
                (action) -> Void in
                print ("ok :( Button tapped")
                self.navigationController?.popToRootViewController(animated: true)
                //_ = navigationController?.popToRootViewController(animated: true)

            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func onTimerEnd () {
        getQuestion()
        hideBoxes()
        enableButtons()
    }
    
    func hideBoxes () {
        boxWrongAnswer1.isHidden = true
        boxCorrectAnswer1.isHidden = true
        
        boxWrongAnswer2.isHidden = true
        boxCorrectAnswer2.isHidden = true
        
        boxWrongAnswer3.isHidden = true
        boxCorrectAnswer3.isHidden = true
        
        boxWrongAnswer4.isHidden = true
        boxCorrectAnswer4.isHidden = true
    }
    
    func screenShake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.view.center.x - 10, y: self.view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.view.center.x + 10, y: self.view.center.y))
        
        self.view.layer.add(animation, forKey: "position")
    }
    
    func disableButtons() {
        firstAnswer.isEnabled = false
        secondAnswer.isEnabled = false
        thirdAnswer.isEnabled = false
        fourthAnswer.isEnabled = false
    }
    
    func enableButtons() {
        firstAnswer.isEnabled = true
        secondAnswer.isEnabled = true
        thirdAnswer.isEnabled = true
        fourthAnswer.isEnabled = true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}
