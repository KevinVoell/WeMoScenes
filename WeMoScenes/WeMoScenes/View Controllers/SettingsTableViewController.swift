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
  
  @IBAction func cancelButtonTapped(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let user = FIRAuth.auth()?.currentUser {
      if user.anonymous {
        usernameTextField.text = "Anonymous"
      } else {
        usernameTextField.text = user.email
      }
    }
  }
  
  @IBAction func signoutTapped(sender: AnyObject) {
    do {
      try FIRAuth.auth()?.signOut()
    } catch let signOutError as NSError {
      print(signOutError)
    }
  }
}
