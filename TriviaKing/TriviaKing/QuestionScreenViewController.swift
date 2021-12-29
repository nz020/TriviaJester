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
    
    
    let url: String = "https://opentdb.com/api.php?amount=1&type=multiple&category=";
    let selectedCategory: String = "9" // test
    let currentQuestion: Int = 0;
    
    struct Response: Codable {
        let response_code: Int
        let results: [QuestionDetails]
    }
    
    struct QuestionDetails: Codable {
        let category: String
        let type: String
        let difficulty: String
        let question: String
        let correct_answer: String
        let incorrect_answers: [String]
    }

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
        
        sendApiRequest(url: url)
        
    }
    
    func sendApiRequest(url: String) {
        
        guard let url = URL(string: url + selectedCategory) else {
            print("Error: cannot create URL")
            return
        }
        
        //let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: url, completionHandler: { data,response,error in
            
            guard let data = data, error == nil else {
                print("error when fetching data")
                return
            }
            
            var result: Response?
            do {
                result = try JSONDecoder().decode(Response.self, from: data)
            }
            catch {
                print ("failed to decode data, Error: \(error)")
            }
            
            guard let json = result else {
                return
            }
            print (json.response_code)
            print (json.results)
            
            DispatchQueue.main.async {
                self.questionLabel.text = json.results[self.currentQuestion].question
                self.difficultyLabel.text = json.results[self.currentQuestion].difficulty
                self.randomizePositionOfCorrectAnswer(correctAnswer: json.results[self.currentQuestion].correct_answer, wrongAnswers: json.results[self.currentQuestion].incorrect_answers)
                self.overlay?.removeFromSuperview()
            }

        })
        task.resume()
        
    }
    
    func randomizePositionOfCorrectAnswer(correctAnswer: String, wrongAnswers: [String]) {
        
        var answersArray: [String] = [correctAnswer] + wrongAnswers;
        answersArray.shuffle()
        
        self.firstAnswer.setTitle(answersArray[0], for: .normal)
        self.secondAnswer.setTitle(answersArray[1], for: .normal)
        self.thirdAnswer.setTitle(answersArray[2], for: .normal)
        self.fourthAnswer.setTitle(answersArray[3], for: .normal)
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

