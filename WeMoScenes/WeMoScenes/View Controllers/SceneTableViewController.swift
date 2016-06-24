//
//  SceneTableViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/21/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import Firebase

class SceneTableViewController: UITableViewController,
                                ManagerDelegate {
  
  /**
    The ApiManager class for the SceneModel
  */
  private lazy var databaseManager = ApiManager<SceneModel>()
  
  /**
    
  */
  private var shownViewController : UINavigationController?
  
  /**
    The settings UINavigationController
  */
  var settingsVC: UINavigationController?

  override func viewDidLoad() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    FIRAuth.auth()?.addAuthStateDidChangeListener(self.handleAuthChange)
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Scenes"
    } else {
      return "Switches"
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("sceneCell") as! SceneTableViewCell;
    
    cell.prepareForReuse()
    
    if indexPath.section == 0 {
      let item = self.databaseManager.items[indexPath.row]
      
      cell.title.text = item.name
      cell.scene = item
    } else {
      let item = AppDelegate.manager?.items[indexPath.row]
      
      cell.title.text = item?.friendlyName
      cell.device = item
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return self.databaseManager.items.count
    } else {
      if AppDelegate.manager != nil {
        return AppDelegate.manager!.items.count
      }
    }
    
    return 0
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
      if indexPath.section == 0 {
        let item = self.databaseManager.items[indexPath.row]
        self.databaseManager.delete(item)
      } else {
        let item = AppDelegate.manager!.items[indexPath.row]
        AppDelegate.manager!.delete(item)
      }
    })
    
    deleteAction.backgroundColor = UIColor.redColor()
    
    if indexPath.section == 0 {
      let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in

        let item = self.databaseManager.items[indexPath.row]
        self.performSegueWithIdentifier("editSceneSegue", sender: item)
        
      })
      
      return [deleteAction, editAction]
    }
    
    return [deleteAction]
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.identifier! {
      case "newSceneSegue:
        let destinationViewController = segue.destinationViewController as! UINavigationController
        let destination = destinationViewController.viewControllers[0] as! SceneEditorTableTableViewController
        destination.sceneManager = self.databaseManager
      
      case "editSceneSegue":
        if let destinationViewController = segue.destinationViewController as? UINavigationController {
          if let destination = destinationViewController.viewControllers[0] as? SceneEditorTableTableViewController {
              destination.currentModel = sender as? SceneModel
              destination.sceneManager = self.databaseManager
          }
        }      
        
      case "signinSegue":
        self.shownViewController = segue.destinationViewController as? UINavigationController
        
      case "settingsSegue:
        self.settingsVC = segue.destinationViewController as? UINavigationController
        
      default
        break
    }
  }
  
  /**
    Called when new Devices or Scenes are found in the datastore.
  */
  func itemAdded() {
    self.tableView!.reloadData()
  }
  
  /**
    Handles changes in authentication by either hiding or showing the 
    login view.
    
    - parameters:
      - auth: The current FIRAuth object
      - user: The current FIRUser object, or null if no user signed in
  */
  func handleAuthChange(auth: FIRAuth, user : FIRUser) {
    if user == nil {
      // TODO: Shutdown services
      AppDelegate.manager = nil
      if self.settingsVC != nil {
        self.settingsVC!.dismissViewControllerAnimated(true, completion: { 
          self.performSegueWithIdentifier("signinSegue", sender: nil)
        })
      } else {
        self.performSegueWithIdentifier("signinSegue", sender: nil)
      }
    } else {
      if (AppDelegate.manager != nil) {
        return
      }
      
      if self.shownViewController != nil {
        self.shownViewController?.dismissViewControllerAnimated(true, completion: { self.setup(user!) })
      } else {
        self.setup(user!)
      }
    }
  }
  
  /** 
    Sets up and starts services when a user login.
  */
  func setup(user: FIRUser) {
    // TODO: Probably don't need this since we can get the User from the FIRAuth object
    AppDelegate.user = user
    
    // Start the Device watcher on the AppDelegate
    // TODO: We might be able to make this a singleton class instead of having it live on the AppDelegate.
    AppDelegate.manager = ApiManager<DeviceModel>()
    AppDelegate.manager!.delegate = self
    AppDelegate.manager!.startWatching()
    
    // Start looking for devices on the local network
    // TODO: This can probably be made a singleton object
    AppDelegate.deviceInteration  = DeviceInteraction()
    AppDelegate.deviceInteration!.findDevices()
    
    // Start Scene watcher
    self.databaseManager.delegate = self;
    self.databaseManager.startWatching()
    
    // This creates a default scene if one doesn't exist.
    // TODO: I don't like this, lets look at removing it.
    let manager = ApiManager<SceneModel>()
    manager.exists("All Switches", callback: { (exists) in
      // TODO: Create default scene.
      if (!exists) {
        let scene = SceneModel(withName: "All Switches")
        
        manager.save(scene)
      }
    })
  }
}
