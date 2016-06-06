//
//  ViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/3/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import Firebase
import WeMoInteraction

class ViewController: UINavigationController,
                      UIPageViewControllerDataSource,
                      UIPageViewControllerDelegate {

  private var pageViewController: UIPageViewController?
  
  private var databaseReference: FIRDatabaseReference!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.databaseReference = FIRDatabase.database().reference()
    
    //pageViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController)
    //pageViewController?.dataSource = self
    
    self.pageViewController = (self.viewControllers[0] as! UIPageViewController)
    
    self.pageViewController?.dataSource = self
    self.pageViewController?.delegate = self
    
    FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
      if user != nil {
        let startingViewController = self.viewControllerAtIndex(0)
        var viewControllers = Array<PageContentViewController>()
        viewControllers.append(startingViewController)
    
        self.pageViewController?.navigationItem.title = "Test Scene \(startingViewController.pageIndex!)"
        
        self.pageViewController?.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
      } else {
        // No user is signed in.
      }
    }
    
    
    //self.addChildViewController(pageViewController!)
    //self.view.addSubview((pageViewController?.view)!)
    pageViewController?.didMoveToParentViewController(self)
    
    
    //self.databaseReference.child("Tests").child(AppDelegate.user!.uid).setValue(["test": "Hello World"])
    
    //self.databaseReference.child("Testing").child("user.uid").setValue(["test2": "Hello There!"])
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  internal func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! PageContentViewController).pageIndex
    
    if (index == 0 || index == NSNotFound) {
      return nil
    }
    
    index! -= 1
    
    return self.viewControllerAtIndex(index!)
  }
  
  internal func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! PageContentViewController).pageIndex
    
    if (index == NSNotFound) {
      return nil
    }
    
    let device = DeviceDataModel()
    device.friendlyName = "Kevin Voell \(index)"
    device.ipAddress = "192.128.0.1"
    device.port = "51428"
    
    
    self.databaseReference.child("Tests")
      .child(AppDelegate.user!.uid)
      .child("\(index)")
      .setValue(device.toJson())
    
    index! += 1
    
    return self.viewControllerAtIndex(index!)
  }
  
  internal func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 4
  }

  internal func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
  }
  
  /**
   *
   */
  internal func viewControllerAtIndex(index: Int) -> PageContentViewController {
    
    let pageContentViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as! PageContentViewController)
    
    pageContentViewController.sceneName = "Test Scene \(index)"
    pageContentViewController.pageIndex = index
    
    return pageContentViewController
    
  }
  
  internal func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    
    let pageViewController = (pendingViewControllers[0] as! PageContentViewController)
    
    self.pageViewController?.navigationItem.title = "Test Scene \(pageViewController.pageIndex!)"
  }
}

