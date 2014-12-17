//
//  DataViewController.swift
//  Workout Buddy
//
//  Created by Chung Ng on 12/12/14.
//  Copyright (c) 2014 Chung Ng. All rights reserved.
//

import UIKit
import CoreData

class DataViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var dataObject: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let obj: ExerciseModelData = dataObject as? ExerciseModelData {
            self.dataLabel!.text = obj.name.valueForKey("name") as String?
        } else {
            self.dataLabel!.text = ""
        }
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            if let obj: ExerciseModelData = dataObject as? ExerciseModelData {
                if(obj.entries.count == 0) {
                    return 1
                } else {
                    return obj.entries.count
                }
            }
            else {
                return 1
            }
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
                as UITableViewCell
            
            if let obj: ExerciseModelData = dataObject as? ExerciseModelData {
                if(obj.entries.count > 0) {
                    let entry: NSManagedObject = obj.entries[indexPath.row]
                    let weight = entry.valueForKey("weight") as? Double
                    let reps = entry.valueForKey("reps") as? Int
                    let date = entry.valueForKey("date") as? NSDate
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
                    dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
                    
                    cell.textLabel!.text = "\(dateFormatter.stringFromDate(date!))\t\(weight!) lbs\t\(reps!) reps"
                }
                else {
                    cell.textLabel!.text = "No entries. Get to work slacker!"
                }
            }
            
            return cell
    }
    
}

