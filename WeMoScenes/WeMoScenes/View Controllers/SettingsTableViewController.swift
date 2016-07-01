//
//  SettingsViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/23/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
  @IBOutlet weak var signoutButtonCell: UITableViewCell!
  @IBOutlet weak var usernameTextField: UILabel!
  @IBOutlet weak var signoutButton: UIButton!
  
  @IBAction func cancelButtonTapped(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let user = FIRAuth.auth()?.currentUser {
      if user.anonymous {
        usernameTextField.text = "Anonymous"
        
        //signoutButton.setTitle("Create Account", forState: .Normal)
      } else {
        usernameTextField.text = user.email
      }
    }
  }
  
  @IBAction func signoutTapped(sender: AnyObject) {
    if let user = FIRAuth.auth()?.currentUser {
      if user.anonymous {
        do {
          try FIRAuth.auth()!.currentUser?.deleteWithCompletion(nil)
        } catch let signOutError as NSError {
          print(signOutError)
        }
      } else {
        do {
          try FIRAuth.auth()!.signOut()
        } catch let signOutError as NSError {
          print(signOutError)
        }
      }
    }
  }
}
