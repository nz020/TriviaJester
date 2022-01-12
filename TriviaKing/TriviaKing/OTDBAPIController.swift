//
//  OTDBAPIController.swift
//  TriviaKing
//
//  Created by Chris Spiegel on 12.01.22.
//

import Foundation

struct Response: Codable {
    let response_code: Int
    let results: [Question]
}

struct TokenResponse: Codable {
    let response_code: Int
    let token: String
}

struct Question: Codable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct OTDBAPIController {
    
    static let INSTANCE = OTDBAPIController()
    private init(){}
    
    let URL_BY_CATEGORY = "https://opentdb.com/api.php?amount=1&type=multiple&encode=url3986&category="
    let URL_GET_TOKEN = "https://opentdb.com/api_token.php?command=request"
    static var session_token: String = ""
    
    func getQuestion(category: String, callback: @escaping([Question]?) -> Void) {
        
        guard let url = URL(string: URL_BY_CATEGORY + category + "&token=" + OTDBAPIController.session_token) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: urlRequest, completionHandler: { data,response,error in
         
            guard let data = data, error == nil else {
                print("error when fetching data")
                return
            }
            
            let questionResults = parseData(data: data)
            callback(questionResults)
        })
        task.resume()
    }
    
    func requestToken() {
        guard let url = URL(string: URL_GET_TOKEN) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: urlRequest) { data,response,error in
            
            guard let data = data, error == nil else {
                print("error when fetching data")
                return
            }
            
            var result: TokenResponse?
            do {
                result = try JSONDecoder().decode(TokenResponse.self, from: data)
                if(result?.response_code == 0) {
                    OTDBAPIController.session_token = result?.token ?? ""
                    print("Retrieved Token successfully! Token is: " + OTDBAPIController.session_token)
                } else {
                    print("Error retrieving token")
                }
                
            }
            catch {
                print ("failed to decode token-data, Error: \(error)")
            }
            
        }
        task.resume()
    }
    
    func parseData(data: Data) -> [Question] {
        var questionResults = [Question]()
        guard let questions = try? JSONDecoder().decode(Response.self, from: data) else {
            print("Failed to decode questions.")
            return questionResults
        }
        
        if(questions.response_code == 4) {
            return questionResults
        }
        
        for question in questions.results {
            questionResults.append(question)
        }
        
        return questionResults
    }
    
}
