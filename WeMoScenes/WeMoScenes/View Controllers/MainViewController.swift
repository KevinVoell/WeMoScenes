//
//  MainViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/23/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {
  
  var show: Int?
  var shownViewController : UINavigationController?

  override func viewDidLoad() {
    super.viewDidLoad()
    

  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    self.shownViewController = segue.destinationViewController as? UINavigationController
  }
}
