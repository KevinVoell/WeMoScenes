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
  
  private lazy var databaseManager = ApiManager<SceneModel>()
  
  private var shownViewController : UINavigationController?

  override func viewDidLoad() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.handleAuthChange()
    
//    FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
//      if user != nil {
//        // Setup the data manager
//        self.databaseManager.delegate = self;
//        self.databaseManager.startWatching()
//        
//        AppDelegate.manager?.delegate = self
//      }
//    })
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
    return true //indexPath.section == 0
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
    if segue.identifier! == "newSceneSegue" {
      let destinationViewController = segue.destinationViewController as! UINavigationController
      let destination = destinationViewController.viewControllers[0] as! SceneEditorTableTableViewController
      destination.sceneManager = self.databaseManager
    } else if segue.identifier! == "editSceneSegue" {
      if let destinationViewController = segue.destinationViewController as? UINavigationController {
        if let destination = destinationViewController.viewControllers[0] as? SceneEditorTableTableViewController {
            destination.currentModel = sender as? SceneModel
            destination.sceneManager = self.databaseManager
        }
      }
    } else if segue.identifier! == "signinSegue" {
      self.shownViewController = segue.destinationViewController as? UINavigationController
    } else if segue.identifier! == "settingsSegue" {
      self.settingsVC = segue.destinationViewController as? UINavigationController
    }
  }
  
  var settingsVC: UINavigationController?
  
  func itemAdded() {
    self.tableView!.reloadData()
  }
  
  func handleAuthChange() {
    FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
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
    })
  }
  
  func setup(user: FIRUser) {
    //self.performSegueWithIdentifier("mainSegue", sender: nil)
    
    AppDelegate.user = user
    
    // TODO: Shutdown network connection.
    AppDelegate.manager = ApiManager<DeviceModel>()
    AppDelegate.manager!.startWatching()
    
    self.databaseManager.delegate = self;
    self.databaseManager.startWatching()
    
    AppDelegate.manager?.delegate = self
    
    let manager = ApiManager<SceneModel>()
    manager.exists("All Switches", callback: { (exists) in
      // TODO: Create default scene.
      if (!exists) {
        let scene = SceneModel(withName: "All Switches")
        
        manager.save(scene)
        
      }
    })
    
    AppDelegate.deviceInteration  = DeviceInteraction()
    AppDelegate.deviceInteration!.findDevices()
  }
}
