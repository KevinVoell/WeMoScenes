//
//  PageViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/13/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

internal class PageViewController: UIPageViewController {
  internal var databaseManager: ApiManager<SceneModel>?
  
  internal var currentIndex: Int?
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    switch (segue.identifier!) {
    case "newSceneSegue":
      let destinationViewController = segue.destinationViewController as! UINavigationController
      let destination = destinationViewController.viewControllers[0] as! SceneEditorTableTableViewController
      destination.sceneManager = self.databaseManager
      //destination.currentModel = self.databaseManager!.items[self.currentIndex!]
      break
      
    default:
      break;
    }
  }
}
