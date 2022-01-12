//
//  ViewController.swift
//  TriviaKing
//
//  Created by Nikita Zaripov on 19.12.21.
//

import UIKit

class MainScreenViewController: UIViewController {

    let apiInstance = OTDBAPIController.INSTANCE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        apiInstance.requestToken()
        // Do any additional setup after loading the view.
    }


}

