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
  
  @IBOutlet weak var signinButtonCell: UITableViewCell!
  @IBOutlet weak var createAccountButtonCell: UITableViewCell!
  @IBAction func cancelButtonTapped(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let user = FIRAuth.auth()?.currentUser {
      if user.anonymous {
        usernameTextField.text = "Anonymous"
        signoutButtonCell.hidden = true
        signoutButtonCell.clipsToBounds = true
        createAccountButtonCell.hidden = false
        signinButtonCell.hidden = false
      } else {
        usernameTextField.text = user.email
        signoutButtonCell.hidden = false
        createAccountButtonCell.hidden = true
        signinButtonCell.hidden = true
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
