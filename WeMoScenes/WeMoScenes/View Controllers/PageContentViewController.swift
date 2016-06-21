//
//  PageContentViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/4/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {
  
  @IBOutlet weak var onButton: UIButton!
  @IBOutlet weak var offButton: UIButton!
  @IBOutlet weak var editButton: UIButton!
  
  internal var pageIndex: Int?
  internal var sceneName: String?
  
  /**
   * Holds the current scene
   */
  internal var currentScene: SceneModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.parentViewController!.navigationItem.title = currentScene?.name!
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func onButtonTapped(sender: AnyObject) {
    
    if self.currentScene?.name == "All Switches" {
      for device in (AppDelegate.manager?.items)! {
        device.on()
      }
    }  else {
      
      for device in (self.currentScene?.devices)! {
        
        if let realDevice = (AppDelegate.manager?.items)?.findFirstMatching({$0.UDN == device.deviceId}) {
          
          if device.state == SceneDeviceModel.StateValues.On  {
            realDevice.on()
          } else if device.state == SceneDeviceModel.StateValues.Off {
            realDevice.off()
          }
        }
      }
    }
  }
  
  @IBAction func offButtonTapped(sender: AnyObject) {
    
    if self.currentScene?.name == "All Switches" {
      for device in (AppDelegate.manager?.items)! {
        device.off()
      }
    } else {
      
      for device in (self.currentScene?.devices)! {
        
        if let realDevice = (AppDelegate.manager?.items)?.findFirstMatching({$0.UDN == device.deviceId}) {
          if device.state == SceneDeviceModel.StateValues.On || device.state == SceneDeviceModel.StateValues.Off  {
            realDevice.off()
          }
        }
      }
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier! == "editSceneSegue" {
      if let destinationViewController = segue.destinationViewController as? UINavigationController {
        if let destination = destinationViewController.viewControllers[0] as? SceneEditorTableTableViewController {
          destination.currentModel = currentScene
          
          if let parent = self.parentViewController as? PageViewController {
              destination.sceneManager = parent.databaseManager
          }
        }
      }
    }
  }
}


extension Array {
  
  // Returns the first element satisfying the predicate, or `nil`
  // if there is no matching element.
  func findFirstMatching<L : BooleanType>(predicate: Element -> L) -> Element? {
    for item in self {
      if predicate(item) {
        return item // found
      }
    }
    return nil // not found
  }
}
