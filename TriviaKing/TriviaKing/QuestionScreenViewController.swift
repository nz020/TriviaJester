//
//  QuestionScreenViewController.swift
//  TriviaKing
//
//  Created by Nikita Zaripov on 19.12.21.
//

import UIKit

class QuestionScreenViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var firstAnswer: UIButton!
    @IBOutlet weak var secondAnswer: UIButton!
    @IBOutlet weak var thirdAnswer: UIButton!
    @IBOutlet weak var fourthAnswer: UIButton!
    var overlay : UIView?

    let apiInstance = OTDBAPIController.INSTANCE
    let selectedCategory: String = "9"// test
    
    var numberOfLives: Int = 3
    var currentQuestion: Int = 0
    var questions: [Question] = [Question]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func getQuestion() {
        apiInstance.getQuestion(category: selectedCategory) { result in
            
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
        self.title = "Streak: \(currentQuestion)"
        overlay?.removeFromSuperview()
    }
    
    func randomizePositionOfCorrectAnswer(correctAnswer: String, wrongAnswers: [String]) {
        
        var answersArray: [String] = [correctAnswer] + wrongAnswers;
        answersArray.shuffle()
        
        self.firstAnswer.setTitle(answersArray[0].removingPercentEncoding, for: .normal)
        self.secondAnswer.setTitle(answersArray[1].removingPercentEncoding, for: .normal)
        self.thirdAnswer.setTitle(answersArray[2].removingPercentEncoding, for: .normal)
        self.fourthAnswer.setTitle(answersArray[3].removingPercentEncoding, for: .normal)
    }
    
    @IBAction func firstAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = String(sender.title(for: .normal) ?? "")
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        getQuestion()
    }
    
    @IBAction func secondAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = String(sender.title(for: .normal) ?? "")
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        getQuestion()
    }
    
    @IBAction func thirdAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = String(sender.title(for: .normal) ?? "")
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        getQuestion()
    }
    
    @IBAction func fourthAnswerOnClick(_ sender: UIButton) {
        let buttonTitle = String(sender.title(for: .normal) ?? "")
        
        checkCorrectAnswer(givenAnswer: buttonTitle)
        getQuestion()
    }
    
    func checkCorrectAnswer (givenAnswer: String) {
        let correctAnswer = questions[0].correct_answer
        if (givenAnswer==correctAnswer) {
            print("Correct")
        }
        else {
            print("Wrong")
            numberOfLives -= 1
            checkGameOver()
        }
    }
    
    func checkGameOver () {
        if (numberOfLives < 1) {
            print("You Lost")
            _ = navigationController?.popToRootViewController(animated: true)
        }
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

