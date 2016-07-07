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
    
    self.refreshControl?.addTarget(self, action: #selector(SceneTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    
    FIRAuth.auth()?.addAuthStateDidChangeListener(self.handleAuthChange)
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func handleRefresh(refreshControl: UIRefreshControl) {
    DeviceInteraction.sharedInstance.findDevices()

    refreshControl.endRefreshing()
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return NSLocalizedString("ScenesTableViewSectionTitle", comment: "Section title for the scenes section")
    } 
    
		return NSLocalizedString("SwitchesTableViewSectionTitle", comment: "Section title for the scenes section")
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("sceneCell") as! SceneTableViewCell;
    
    cell.prepareForReuse()
    
    if indexPath.section == 0 {
      let item = self.databaseManager.items[indexPath.row]
      
      cell.title.text = item.name
      cell.scene = item
    } else {
      let item = AppDelegate.deviceModelManager?.items[indexPath.row]
      
      cell.title.text = item?.friendlyName
      cell.device = item
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return self.databaseManager.items.count
    } 

		if AppDelegate.deviceModelManager != nil {
			return AppDelegate.deviceModelManager!.items.count
		}
    
    return 0
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true // All cells can be edited
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Delete" , handler: { 
		(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void 
		[unowned self] in
      if indexPath.section == 0 {
        let item = self.databaseManager.items[indexPath.row]
        self.databaseManager.delete(item)
      } else {
        let item = AppDelegate.deviceModelManager!.items[indexPath.row]
        AppDelegate.deviceModelManager!.delete(item)
      }
    })
    
    deleteAction.backgroundColor = UIColor.redColor()
    
    if indexPath.section == 0 {
      let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, 
											title: "Edit" , 
										  handler: { 
												(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void 
														[unowned self] in
					
														let item = self.databaseManager.items[indexPath.row]
														self.performSegueWithIdentifier("editSceneSegue", sender: item)        
													})
      
      return [deleteAction, editAction]
    }
    
    return [deleteAction]
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch segue.identifier! {
    case "newSceneSegue":
      if let destinationViewController = segue.destinationViewController as! UINavigationController {
				if let destination = destinationViewController.viewControllers[0] as! SceneEditorTableTableViewController {}
					destination.sceneManager = self.databaseManager
				}
			}
    
    case "editSceneSegue":
      if let destinationViewController = segue.destinationViewController as? UINavigationController {
        if let destination = destinationViewController.viewControllers[0] as? SceneEditorTableTableViewController {
            destination.currentModel = sender as? SceneModel
            destination.sceneManager = self.databaseManager
        }
      }      
        
    case "signinSegue":
      self.shownViewController = segue.destinationViewController as? UINavigationController
        
    case "settingsSegue":
      self.settingsVC = segue.destinationViewController as? UINavigationController
        
    default:
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
  func handleAuthChange(auth: FIRAuth?, user : FIRUser?) {
    if user == nil {
      self.stop()
      
      if self.settingsVC != nil {
        self.settingsVC!.dismissViewControllerAnimated(true, completion: {
					[unowned self] in
					self.performSegueWithIdentifier("signinSegue", sender: nil)
        })
      } else {
        self.performSegueWithIdentifier("signinSegue", sender: nil)
      }
    } else {
      if self.shownViewController != nil {
        self.shownViewController?.dismissViewControllerAnimated(true, completion: { self.setup(user!) })
      }
      
      self.setup(user!)
    }
  }
  
	/**
		Stops watching for changes in the data model.
	*/
  func stop() {
    if AppDelegate.deviceModelManager != nil {
      AppDelegate.deviceModelManager!.stopWatching()
    }
    
    self.databaseManager.stopWatching()
  }
  
  /** 
    Sets up and starts services when a user login.
  */
  func setup(user: FIRUser) {
    // Start the Device watcher on the AppDelegate
    if AppDelegate.deviceModelManager == nil {
      AppDelegate.deviceModelManager = ApiManager<DeviceModel>()
      AppDelegate.deviceModelManager!.delegate = self
    }
    
    AppDelegate.deviceModelManager!.startWatching()
    
    // Start looking for devices on the local network
    DeviceInteraction.sharedInstance.findDevices()
    
    // Start Scene watcher
    self.databaseManager.delegate = self;
    self.databaseManager.startWatching()
  }
  
	/**
		Called when the add button is tapped.
	*/
  @IBAction func addButtonTapped(sender: AnyObject) {
    performSegueWithIdentifier("newSceneSegue", sender: self)
  }
}
