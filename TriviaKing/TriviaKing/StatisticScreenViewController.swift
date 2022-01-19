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
    var database: LocalStorageController? = nil
    var highestStreakCat: CDCategory = CDCategory()
    var totalRounds: Int = 0
    var mostPlayedCat: CDCategory = CDCategory()
    var bestCat: CDCategory = CDCategory()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        database = LocalStorageController(delegate: appDelegate)
        loadData()
        setLabels()
    }
    
    func loadData() {
        highestStreakCat = database?.getLongestStreak() ?? CDCategory()
        totalRounds = calculateTotalRounds(categories: database?.getAllCategories() ?? [CDCategory]())
        mostPlayedCat = database?.getMostPlayed() ?? CDCategory()
        bestCat = database?.getBestAnswerRatio() ?? CDCategory()
    }
    
    func calculateTotalRounds(categories: [CDCategory]) -> Int {
        var total = 0
        for category in categories {
            total += Int(category.timesPlayed)
        }
        return total
    }
    
    func setLabels() {
        HighestStreak.text = String(highestStreakCat.longestStreak)
        TotalRounds.text = String(totalRounds)
        
        MostPlayedCat.text = mostPlayedCat.name
        MostPlayedCatTime.text = String(mostPlayedCat.timesPlayed)
        
        BestCat.text = bestCat.name
        BestCatTime.text = String(bestCat.timesPlayed)
        BestCatStreak.text = String(bestCat.longestStreak)
        BestCatCorrect.text = String(bestCat.answeredRight)
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
