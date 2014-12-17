//
//  ModelController.swift
//  Workout Buddy
//
//  Created by Chung Ng on 12/12/14.
//  Copyright (c) 2014 Chung Ng. All rights reserved.
//

import UIKit
import CoreData

/*
 A controller object that manages a simple model -- a collection of exercise names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    var exerciseNames = NSArray() // Exercise name (pages)
    var exerciseData = NSArray()     // Exercise data (entries)

    override init() {
        super.init()
        // Create the data model.
        let dateFormatter = NSDateFormatter()
        exerciseNames = fetchExerciseNames();
        exerciseData = [NSManagedObject]()
    }
    
    func sortExercise(o1:AnyObject, o2:AnyObject) -> Bool {
        return o2.name > o1.name
    }
    
    func sortEntries(o1:NSManagedObject, o2:NSManagedObject) -> Bool {
        return (o1.valueForKey("date") as NSDate).timeIntervalSinceDate(o2.valueForKey("date") as NSDate) < 0
    }
    
    func fetchExerciseNames() -> [NSManagedObject] {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Exercise")
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            if(results.count>0) {
                return sorted(results, sortExercise)
            } else {
                let entity =  NSEntityDescription.entityForName("Exercise", inManagedObjectContext:managedContext)
                
                // Prepopulate with default exercises
                for name in ["Back","Chest","Legs","Shoulders"] {
                    let exercise = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                    exercise.setValue(name, forKey: "name")
                }
                
                let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
                if let results = fetchedResults {
                    return sorted(results, sortExercise)
                } else {
                    return [NSManagedObject]()
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return [NSManagedObject]()
        }
    }
    
    func fetchExerciseEntries(exerciseName : String) -> [NSManagedObject] {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"ExerciseEntry")
        fetchRequest.predicate = NSComparisonPredicate(format: "%K == %@", "name", exerciseName)
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            return sorted(results, sortEntries)
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return [NSManagedObject]()
        }
    }
    
    func addEntry(name: String, weight: Double, reps: Int) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("ExerciseEntry", inManagedObjectContext:managedContext)
        var error: NSError?
        
        let dateTime = NSDate()
        let exerciseEntry = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        exerciseEntry.setValue(name, forKey: "name")
        exerciseEntry.setValue(weight, forKey:"weight")
        exerciseEntry.setValue(reps, forKey:"reps")
        exerciseEntry.setValue(dateTime, forKey:"date")
        
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }

    func getDataObject(index: Int) -> ExerciseModelData {
        return ExerciseModelData(name: self.exerciseNames[index] as NSManagedObject, entries: fetchExerciseEntries(self.exerciseNames[index].valueForKey("name") as String))
    }
    
    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        // if (self.pageData.count == 0) || (index >= self.pageData.count) {
        if (self.exerciseNames.count == 0) || (index >= self.exerciseNames.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as DataViewController
        let data = getDataObject (index)
        dataViewController.dataObject = data
        return dataViewController
    }

    func indexOfViewController(viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        if let dataObject: AnyObject = viewController.dataObject {
            
            return self.exerciseNames.indexOfObject((dataObject as ExerciseModelData).name)
        } else {
            return NSNotFound
        }
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as DataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == self.exerciseNames.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

}

class ExerciseModelData {
    var name : NSManagedObject
    var entries : [NSManagedObject]
    
    init(name:NSManagedObject, entries:[NSManagedObject]) {
        self.name = name
        self.entries = entries
    }
}