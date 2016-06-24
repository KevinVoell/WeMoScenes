//
//  SettingsViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/23/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

  @IBAction func cancelTapped(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func signoutTapped(sender: AnyObject) {
    do {
      try FIRAuth.auth()?.signOut()
    } catch let signOutError as NSError {
      print(signOutError)
    }
  }
}
