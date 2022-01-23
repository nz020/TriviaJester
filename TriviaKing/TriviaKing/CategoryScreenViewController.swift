//
//  CategoryScreenViewController.swift
//  TriviaKing
//
//  Created by Nikita Zaripov on 19.12.21.
//

import UIKit

class CategoryScreenViewController: UIViewController {
    
    @IBOutlet weak var categoryLabel: UILabel!
    let font = UIFont(name: "Hey Comic", size: 24)
    
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
    
    var selectedCategory: String?
    
    @IBOutlet weak var Category1ButtonOutlet: UIButton!
    
    @IBOutlet weak var Category2ButtonOutlet: UIButton!
    
    @IBOutlet weak var Category3ButtonOutlet: UIButton!
    
    @IBOutlet weak var Category4ButtonOutlet: UIButton!
    
    @IBAction func Category1Button(_ sender: UIButton) {
        selectedCategory = categories[Category1ButtonOutlet.titleLabel?.text ?? ""]
        buttonPressed()
    }
    
    @IBAction func Category2Button(_ sender: UIButton) {
        selectedCategory = categories[Category2ButtonOutlet.titleLabel?.text ?? ""]
        buttonPressed()
    }
    
    @IBAction func Category3Button(_ sender: UIButton) {
        selectedCategory = categories[Category3ButtonOutlet.titleLabel?.text ?? ""]
        buttonPressed()
    }
    
    @IBAction func Category4Button(_ sender: UIButton) {
        selectedCategory = categories[Category4ButtonOutlet.titleLabel?.text ?? ""]
        buttonPressed()
    }
    
    func buttonPressed(){
        self.performSegue(withIdentifier: "categorySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! QuestionScreenViewController
        destinationVC.selectedCategory = selectedCategory
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tempCategories = categories
        
        let randomCategory1 = tempCategories.keys.randomElement()
        tempCategories.removeValue(forKey: randomCategory1 ?? "")
        
        let randomCategory2 = tempCategories.keys.randomElement()
        tempCategories.removeValue(forKey: randomCategory2 ?? "")
        
        let randomCategory3 = tempCategories.keys.randomElement()
        tempCategories.removeValue(forKey: randomCategory3 ?? "")
        
        let randomCategory4 = tempCategories.keys.randomElement()
        
        let attributedCategoryString = NSAttributedString(
            string: "Choose a Category",
            attributes: [
                NSAttributedString.Key.strokeColor: UIColor.black,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.strokeWidth: -4.0,
            ]
        )
        categoryLabel.attributedText = attributedCategoryString
        categoryLabel.font = UIFont(name: "Hey Comic", size: 42)
        
        Category1ButtonOutlet.layer.borderWidth = 2
        Category2ButtonOutlet.layer.borderWidth = 2
        Category3ButtonOutlet.layer.borderWidth = 2
        Category4ButtonOutlet.layer.borderWidth = 2
  
        Category1ButtonOutlet.layer.cornerRadius = 12
        Category2ButtonOutlet.layer.cornerRadius = 12
        Category3ButtonOutlet.layer.cornerRadius = 12
        Category4ButtonOutlet.layer.cornerRadius = 12
        
        Category1ButtonOutlet.setAttributedTitle(NSAttributedString(string: randomCategory1!, attributes: [NSAttributedString.Key.font: font!]), for: .normal)
        Category2ButtonOutlet.setAttributedTitle(NSAttributedString(string: randomCategory2!, attributes: [NSAttributedString.Key.font: font!]), for: .normal)
        Category3ButtonOutlet.setAttributedTitle(NSAttributedString(string: randomCategory3!, attributes: [NSAttributedString.Key.font: font!]), for: .normal)
        Category4ButtonOutlet.setAttributedTitle(NSAttributedString(string: randomCategory4!, attributes: [NSAttributedString.Key.font: font!]), for: .normal)
        
        
        
    }
}
