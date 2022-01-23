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
    var currentQuestion: Int = 0
    var questions: [Question] = [Question]()
    
    var secondsBeforeNextQuestion: Int = 5
    
    var categories = ["General Knowledge": "9",
                    "Books": "10",
                    "Film/Movies": "11",
                    "Music": "12",
                    "Video Games": "15",
                    "Computers": "18",
                    "Sports": "21",
                    "Celebrities": "26",
                    "Comics": "29",
                    "Anime/Manga": "31"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideBoxes()
        
        database = LocalStorageController(delegate: appDelegate)
        numberofLivesLabel.text = "\(numberOfLives)"
        
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
        database?.saveCategory(category: OTDBAPIController.catDict.someKey(forValue: selectedCategory!)!, correctAnswers: (currentQuestion - 3 + numberOfLives), wrongAnswers: (-1 * (numberOfLives-3)), streak: currentQuestion - 3 + numberOfLives)
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
                self.currentQuestion += 1
            }
            
        }
    }
    
    func updateView() {
        questionLabel.text = questions[0].question.removingPercentEncoding
        difficultyLabel.text = questions[0].difficulty.removingPercentEncoding
        randomizePositionOfCorrectAnswer(correctAnswer: questions[0].correct_answer, wrongAnswers: questions[0].incorrect_answers)
        self.title = "\(categories.someKey(forValue: selectedCategory ?? "0") ?? "Default Category")"
        overlay?.removeFromSuperview()
    }
    
    func randomizePositionOfCorrectAnswer(correctAnswer: String, wrongAnswers: [String]) {
        
        var answersArray: [String] = [correctAnswer] + wrongAnswers;
        answersArray.shuffle()
        
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
        showCorrectAnswer()
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onTimerEnd), userInfo: nil, repeats: false)
        //getQuestion()
    }
    
    @IBAction func secondAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = "\(sender.title(for: .normal) ?? "")"
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        showCorrectAnswer()
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onTimerEnd), userInfo: nil, repeats: false)
        //getQuestion()
    }
    
    @IBAction func thirdAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = "\(sender.title(for: .normal) ?? "")"
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        showCorrectAnswer()
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onTimerEnd), userInfo: nil, repeats: false)
        //getQuestion()
    }
    
    @IBAction func fourthAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = "\(sender.title(for: .normal) ?? "")"
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        showCorrectAnswer()
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onTimerEnd), userInfo: nil, repeats: false)
        //getQuestion()
    }
    
    func checkCorrectAnswer (givenAnswer: String) {
        let correctAnswer = questions[0].correct_answer.removingPercentEncoding ?? ""
        let clicked = givenAnswer.removingPercentEncoding ?? ""
        print(correctAnswer)
        
        print(clicked)
        
        if (clicked==correctAnswer) {
            isAnswerCorrect = true
            print("Correct")
        }
        else {
            print("Wrong")
            isAnswerCorrect = false
            numberOfLives -= 1
            numberofLivesLabel.text = "\(numberOfLives)"
            checkGameOver()
        }
    }
    
    func showCorrectAnswer () {
        let correctAnswer = questions[0].correct_answer.removingPercentEncoding ?? ""
        var correctAnswerNumber: Int = 0
        
        if (correctAnswer == firstAnswer.titleLabel?.text) {
            correctAnswerNumber = 1
        }
        else if (correctAnswer == secondAnswer.titleLabel?.text) {
            correctAnswerNumber = 2
        }
        else if (correctAnswer == thirdAnswer.titleLabel?.text) {
            correctAnswerNumber = 3
        }
        else if (correctAnswer == fourthAnswer.titleLabel?.text) {
            correctAnswerNumber = 4
        }
        showCorrectBoxes(answerNumber: correctAnswerNumber)
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
            print("You Lost")
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func onTimerEnd () {
        getQuestion()
        hideBoxes()
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
