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

  override func viewDidLoad() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
      if user != nil {
        // Setup the data manager
        self.databaseManager.delegate = self;
        self.databaseManager.startWatching()
        
        AppDelegate.manager?.delegate = self
      }
    })
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
    }
  }
  
  func itemAdded() {
    self.tableView!.reloadData()
  }
}
