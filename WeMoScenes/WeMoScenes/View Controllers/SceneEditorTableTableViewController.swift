//
//  SceneEditorTableTableViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/4/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import Firebase

class SceneEditorTableTableViewController:
                                          UITableViewController,
                                          ManagerDelegate,
                                          SwitchTableViewCellDelegate {
  
  /**
   * manager: The data manager for the device model
   */
  private weak var manager: ApiManager<DeviceModel>?
  
  /**
   * sceneManager: The data manager for the scene table.
   */
  internal var sceneManager: ApiManager<SceneModel>!
  
  /**
   * currentModel: The current scene model that is being edited.
   */
  internal var currentModel: SceneModel?
  
  private var isNew: Bool = false
  
  @IBOutlet weak var titleTextFIeld: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.manager = AppDelegate.deviceModelManager
    
    
    if self.currentModel == nil {
      self.isNew = true;
      self.navigationController!.toolbarHidden = true
      self.navigationItem.title = NSLocalizedString("NewSceneNavigationBarTitle", comment: "Title for the new scene view")
      
      self.currentModel = SceneModel(withName: "")
    } else {
      self.navigationItem.title = NSLocalizedString("EditSceneNavigationBarTitle", comment: "Title for the edit scene view")
    }
    
    titleTextFIeld.text = self.currentModel!.name
  }
  
  @IBAction func cancelButtonTapped(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func saveButtonTapped(sender: AnyObject) {
    if titleTextFIeld.text == "" {
      self.showAlert(NSLocalizedString("ErrorTitle", comment: "Title for the error alert"),
                     message: NSLocalizedString("SceneTitleMissingMessage", comment: "Message shown when trying to save scene with no title"),
          dismissButtonTitle: NSLocalizedString("DismissButtonTitle", comment: "Title for the dismiss button"),
           completionHandler: nil,
           additionalButtons: nil)
    } else {
      self.currentModel?.name = titleTextFIeld.text
      self.sceneManager.save(self.currentModel!)
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.manager!.items.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("switchCell", forIndexPath: indexPath) as! SwitchTableViewCell
    
    let device = self.manager!.items[indexPath.row]
    
    var sceneDeviceModel: SceneDeviceModel?
    
    for tempdevice in self.currentModel!.devices! {
      if (tempdevice.deviceId == device.UDN) {
        sceneDeviceModel = tempdevice
        break
      }
    }
    
    if (sceneDeviceModel == nil) {
      sceneDeviceModel = SceneDeviceModel()
      sceneDeviceModel?.deviceId = device.UDN
      sceneDeviceModel?.state = SceneDeviceModel.StateValues.On
      currentModel?.devices?.append(sceneDeviceModel!)
    }
    
    cell.title .text = self.manager!.items[indexPath.row].friendlyName
    cell.stateSwitch.selectedSegmentIndex = (sceneDeviceModel?.state?.rawValue)!
    cell.sceneDeviceModel = sceneDeviceModel!
    cell.delegate = self
    
    return cell
  }
  
  @IBAction func trashTapped(sender: AnyObject) {
    sceneManager.delete(currentModel!)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
 
  internal func itemAdded() {
    print("New item added, total count: \(self.manager!.items.count)")
    
    self.tableView!.reloadData()
  }
  
  func switchValue(changedTo: Bool, forSceneViewModel: SceneDeviceModel) {
    //self.sceneManager.save(self.currentModel!)
  }
}
