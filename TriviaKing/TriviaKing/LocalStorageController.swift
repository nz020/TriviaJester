//
//  LocalStorageController.swift
//  TriviaKing
//
//  Created by Chris Spiegel on 29.12.21.
//

import Foundation
import CoreData


struct LocalStorageController {
    
    var delegate: AppDelegate?
    var context: NSManagedObjectContext
    
    init(delegate: AppDelegate) {
        self.delegate = delegate
        self.context = delegate.persistentContainer.viewContext
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAllCategories() -> [CDCategory] {
        var savedCategories: [CDCategory] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDCategory")
        
        do {
            let results = try context.fetch(request)
            savedCategories += results as! [CDCategory]
        } catch let error {
            print(error)
            print("Error fetching all Categories.")
        }
        
        return savedCategories
    }
    
    func getMostPlayed() -> CDCategory? {
        var mostPlayedCategory: CDCategory?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDCategory")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "timesPlayed", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            if(results.count > 0) {
                mostPlayedCategory = results[0] as? CDCategory
            }
        } catch let error {
            print(error)
            print("Error fetching most played Category.")
        }
        
        return mostPlayedCategory
    }
    
    func getLongestStreak() -> CDCategory? {
        var longestStreakCategory: CDCategory?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDCategory")
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "longestStreak", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            if(results.count > 0) {
                longestStreakCategory = results[0] as? CDCategory
            }
        } catch let error {
            print(error)
            print("Error fetching longest Streak.")
        }
        
        return longestStreakCategory
    }
    
    func getBestAnswerRatio() -> CDCategory? {
        let allCategories = getAllCategories()
        var bestCategory: CDCategory?
        if (allCategories.count > 0) {
            bestCategory = allCategories[0]
        } else {
            bestCategory = nil
        }
        
        
        // There might be a better way to sort by the ratios.
        // ToDo: Look into alternatives for this function
        for category in allCategories {
            let categoryRatio = (Float(category.answeredRight) / (Float(category.answeredRight) + Float(category.answeredWrong)))
            if(bestCategory != nil) {
                let bestRatio = (Float(bestCategory!.answeredRight) / (Float(bestCategory!.answeredRight) + Float(bestCategory!.answeredWrong)))
                if(categoryRatio >= bestRatio) {
                    bestCategory = category
                }
            } else {
                bestCategory = category
            }
            
            
        }
        
        return bestCategory
    }
    
    func categoryExists(name: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDCategory")
        request.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let results = try context.fetch(request)
            
            return (!results.isEmpty)
        } catch let error {
            print(error)
            print("Error checking whether category is already saved.")
        }
        
        return false
    }
    
    // Returns Category as NSManagedObject so we can update values easily.
    func getCategoryByName(name: String) -> NSManagedObject {
        var savedCategory: NSManagedObject = NSManagedObject()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDCategory")
        request.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let results = try context.fetch(request)
            
            savedCategory = results[0] as! NSManagedObject
        } catch let error {
            print(error)
            print("Error fetching saved category with name: " + name)
        }
        
        return savedCategory
    }
    
    func saveCategory(category name: String, correctAnswers: Int, wrongAnswers: Int, streak: Int) -> Void {
        
        if(categoryExists(name: name)) {
            // Not sure if there is a nicer solution than this. Gonna look into it.
            let savedCategory = getCategoryByName(name: name)
            
            let newCorrect = savedCategory.value(forKey: "answeredRight") as! Int64 + Int64(correctAnswers)
            let newWrong = savedCategory.value(forKey: "answeredWrong") as! Int64 + Int64(wrongAnswers)
            let timesPlayed = savedCategory.value(forKey: "timesPlayed") as! Int64 + 1
            
            savedCategory.setValue(newCorrect, forKey: "answeredRight")
            savedCategory.setValue(newWrong, forKey: "answeredWrong")
            savedCategory.setValue(timesPlayed, forKey: "timesPlayed")
            if(Int64(streak) > savedCategory.value(forKey: "longestStreak") as! Int64) {
                savedCategory.setValue(Int64(streak), forKey: "longestStreak")
            }
            
            do {
                try context.save()
            } catch let error {
                print(error)
                print("Error saving CoreData context.")
            }
        } else {
            // Again, gonna look into if there are nicer solutions for this.
            let newCategory = CDCategory(context: context)
            newCategory.name = name
            newCategory.answeredRight = Int64(correctAnswers)
            newCategory.answeredWrong = Int64(wrongAnswers)
            newCategory.longestStreak = Int64(streak)
            newCategory.timesPlayed = 1
            
            do {
                try context.save()
            } catch let error {
                print(error)
                print("Error saving CoreData context.")
            }
        }
        
    }
    
    func deleteAllCat() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDCategory")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error)
            print("Error occured while trying to batch delete data.")
        }
    }
    
    func deleteCat(category name: String) {
        if(categoryExists(name: name)) {
            let savedCategory = getCategoryByName(name: name)
            
            context.delete(savedCategory)
            
            do {
                try context.save()
            } catch {
                print(error)
                print("Error occured while trying to delete category with name: \(name)")
            }
        }
    }
    
    
    
}

