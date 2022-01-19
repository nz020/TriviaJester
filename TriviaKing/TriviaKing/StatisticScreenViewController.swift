//
//  StatisticScreenViewController.swift
//  TriviaKing
//
//  Created by Nikita Zaripov on 19.12.21.
//

import UIKit

class StatisticScreenViewController: UIViewController {
    
    @IBOutlet weak var HighestStreak: UILabel!
    @IBOutlet weak var TotalRounds: UILabel!
    @IBOutlet weak var MostPlayedCat: UILabel!
    @IBOutlet weak var MostPlayedCatTime: UILabel!
    @IBOutlet weak var BestCat: UILabel!
    @IBOutlet weak var BestCatTime: UILabel!
    @IBOutlet weak var BestCatCorrect: UILabel!
    @IBOutlet weak var BestCatStreak: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var database: LocalStorageController?
    var highestStreakCat: CDCategory?
    var totalRounds: Int = 0
    var mostPlayedCat: CDCategory?
    var bestCat: CDCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        database = LocalStorageController(delegate: appDelegate)
        
        DispatchQueue.main.async {
            self.loadData()
            self.setLabels()
            
        }
    }
    
    func loadData() {
        highestStreakCat = database?.getLongestStreak()
        totalRounds = calculateTotalRounds(categories: (database?.getAllCategories())!)
        mostPlayedCat = database?.getMostPlayed()
        bestCat = database?.getBestAnswerRatio()
    }
    
    func calculateTotalRounds(categories: [CDCategory]) -> Int {
        var total = 0
        for category in categories {
            total += Int(category.timesPlayed)
        }
        return total
    }
    
    func setLabels() {
        HighestStreak.text = "\(highestStreakCat?.name ?? ""): \(highestStreakCat?.longestStreak ?? 0)"
        TotalRounds.text = "\(totalRounds)"
        
        MostPlayedCat.text = mostPlayedCat?.name
        MostPlayedCatTime.text = "Times played: \(mostPlayedCat?.timesPlayed ?? 0)"
        
        BestCat.text = bestCat?.name
        BestCatTime.text = "Times Played: \(bestCat?.timesPlayed ?? 0)"
        BestCatStreak.text = "Longest Streak: \(bestCat?.longestStreak ?? 0)"
        BestCatCorrect.text = "Correct Answers: \(bestCat?.answeredRight ?? 0)"
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
