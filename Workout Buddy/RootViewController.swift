//
//  RootViewController.swift
//  Workout Buddy
//
//  Created by Chung Ng on 12/12/14.
//  Copyright (c) 2014 Chung Ng. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?
    var currentViewControllerIndex: Int = 0
    var pendingViewControllerIndex: Int = 0

    @IBOutlet weak var pageControl: UIPageControl!

    // Pops up an alert and adds an entry to the current exercise
    @IBAction func addEntry(sender: AnyObject) {
        let exercise = self.modelController.exerciseNames[self.currentViewControllerIndex].name
        var alert = UIAlertController(title: exercise,
            message: "Add a new entry",
            preferredStyle: .Alert)
        
        //BUGBUG: Need to validate weight field is populated before activating the save button
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                
                let weight = ((alert.textFields![0] as UITextField).text as NSString).doubleValue
                let reps = ((alert.textFields?[1] as UITextField).text as NSString).integerValue
                
                self.modelController.addEntry(exercise, weight: weight, reps: reps)
                
                //self.tableView.reloadData()
                let dataViewController = self.pageViewController!.viewControllers[0] as DataViewController
                dataViewController.dataObject = self.modelController.getDataObject(self.currentViewControllerIndex)

                let tableView:UITableView = self.pageViewController!.viewControllers[0].tableView
                tableView.reloadData()
                
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Weight"
            textField.keyboardType = UIKeyboardType.DecimalPad
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Repetitions"
            textField.keyboardType = UIKeyboardType.DecimalPad
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self

        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers: NSArray = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })

        self.pageViewController!.dataSource = self.modelController

        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        self.pageViewController!.view.frame = pageViewRect

        self.pageViewController!.didMoveToParentViewController(self)

        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
        // Make the navigation bar show
        self.navigationController?.navigationBar.translucent = false

        // Update page control
        pageControl.numberOfPages = self.modelController.exerciseNames.count
        pageControl.currentPage = self.modelController.indexOfViewController(self.pageViewController!.viewControllers[0] as DataViewController)
        
        
        // BUGBUG: Need to hook up UIPageControl's call backs to handle navigation via the pageControl. Disable for now.
        pageControl.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
        let currentViewController = self.pageViewController!.viewControllers[0] as UIViewController
        let viewControllers: NSArray = [currentViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })

        self.pageViewController!.doubleSided = false
        return .Min
    }

    // BUGBUG: There is a bug here. Probably a race condition where playing around with the page transitions in the UI can cause us to fire events out of sequence (theory) and the currentViewController index will be WRONG, thus getting the wrong dot. However, this self corrects after the next transition.
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        self.pendingViewControllerIndex = self.modelController.indexOfViewController(pendingViewControllers[0] as DataViewController)
    }

    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        self.currentViewControllerIndex = self.pendingViewControllerIndex

        // Update page control
        self.pageControl.numberOfPages = self.modelController.exerciseNames.count
        self.pageControl.currentPage = self.currentViewControllerIndex
    }
    
}

