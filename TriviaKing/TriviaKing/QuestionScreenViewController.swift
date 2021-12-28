//
//  QuestionScreenViewController.swift
//  TriviaKing
//
//  Created by Nikita Zaripov on 19.12.21.
//

import UIKit

class QuestionScreenViewController: UIViewController {
    
    let url = "https://opentdb.com/api.php?amount=1";
    
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
        
        sendApiRequest(url: url)

        // Do any additional setup after loading the view.
    }
    
    func sendApiRequest(url: String) {
        
        guard let url = URL(string: url) else {
            print("Error: cannot create URL")
            return
        }
        print(url)
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
            print (json.results[0].category)
            print (json.results)
            
        })
        
        task.resume()
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
