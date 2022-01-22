//
//  TriviaKingTests.swift
//  TriviaKingTests
//
//  Created by Chris Spiegel on 22.01.22.
//

import XCTest
@testable import TriviaKing
import CoreData

class TriviaKingTests: XCTestCase {

    lazy var persistanceContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "TriviaKing")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let erorr = error as NSError? {
                fatalError("Unresolved Error \(error), \(error.debugDescription)")
            }
        }
        
        return container
    }()
    
    var database: LocalStorageController?
    
    override func setUpWithError() throws {
        database = LocalStorageController(context: persistanceContainer.newBackgroundContext())
        
        database?.saveCategory(category: "Test", correctAnswers: 2, wrongAnswers: 1, streak: 2)
        database?.saveCategory(category: "Test2", correctAnswers: 20, wrongAnswers: 1, streak: 20)
        database?.saveCategory(category: "Test3", correctAnswers: 40, wrongAnswers: 1, streak: 3)
        database?.saveCategory(category: "Test4", correctAnswers: 1, wrongAnswers: 1, streak: 1)
        database?.saveCategory(category: "Test4", correctAnswers: 1, wrongAnswers: 1, streak: 1)
        database?.saveCategory(category: "Test4", correctAnswers: 1, wrongAnswers: 1, streak: 1)
    }

    override func tearDownWithError() throws {
        database?.deleteCat(category: "Test1")
        database?.deleteCat(category: "Test2")
        database?.deleteCat(category: "Test3")
        database?.deleteCat(category: "Test4")
    }

    func testDatabaseExists() throws {
        XCTAssertNotNil(database, "Database should exist.")
    }
    
    func testDatabaseSaving() throws {
        XCTAssertTrue(((database?.categoryExists(name: "Test1")) != nil), "Unexpected: Category with name 'Test1' should exist.")
        XCTAssertTrue(((database?.categoryExists(name: "Test2")) != nil), "Unexpected: Category with name 'Test1' should exist.")
        XCTAssertTrue(((database?.categoryExists(name: "Test3")) != nil), "Unexpected: Category with name 'Test1' should exist.")
        XCTAssertTrue(((database?.categoryExists(name: "Test4")) != nil), "Unexpected: Category with name 'Test1' should exist.")
    }
    
    func testDatabaseFunctions() throws {
        XCTAssertEqual(database?.getMostPlayed()?.name, "Test4", "Unexpected: Category 'Test4' should be the most played Category.")
        XCTAssertEqual(database?.getLongestStreak()?.name, "Test2", "Unexpected: Category 'Test2' should have the highest streak.")
        XCTAssertEqual(database?.getLongestStreak()?.answeredRight, 20)
        
        XCTAssertEqual(database?.getBestAnswerRatio()?.name, "Test3", "Unexpected: Category 'Test3' should have the best answer ratio. But \(String(describing: database?.getBestAnswerRatio()?.name)) has the best ratio.")
        
        //test deleting all data
        database?.deleteAllCat()
        XCTAssertTrue(database?.getAllCategories().count == 0, "Unexpected: Categories should have been deleted, but \(String(describing: database?.getAllCategories().count)) Categories were found.")
        
        //testing whether updating a category works
        database?.saveCategory(category: "UpdateTest", correctAnswers: 1, wrongAnswers: 1, streak: 1000000)
        XCTAssertEqual(database?.getLongestStreak()?.name, "UpdateTest")
        XCTAssertEqual(database?.getLongestStreak()?.timesPlayed, 1)
        XCTAssertEqual(database?.getLongestStreak()?.answeredRight, 1)
        
        database?.saveCategory(category: "UpdateTest", correctAnswers: 3, wrongAnswers: 1, streak: 1000000)
        XCTAssertEqual(database?.getLongestStreak()?.name, "UpdateTest")
        XCTAssertEqual(database?.getLongestStreak()?.timesPlayed, 2)
        XCTAssertEqual(database?.getLongestStreak()?.answeredRight, 4)
        
        database?.deleteCat(category: "UpdateTest")
    }
    

    func testDatabaseSavingPerformance() throws {
        measure {
            _ = database?.getAllCategories()
            database?.saveCategory(category: "PerformanceTest", correctAnswers: 0, wrongAnswers: 0, streak: 0)

            //saving an already existing category
            database?.saveCategory(category: "PerformanceTest", correctAnswers: 3, wrongAnswers: 1, streak: 1)
        }
    }
    
    func testDatabaseDeletingPerformance() throws {
        measure {
            database?.deleteCat(category: "PerformanceTest")
        }
    }

}
