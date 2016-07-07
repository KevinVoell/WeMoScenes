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
// TODO: Delete this from IB
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
        usernameTextField.text = NSLocalizedString("AnonymousUserTitle", comment: "Title for an anonymous user")
        signoutButton.setTitle(NSLocalizedString("SigninButtonTitle", comment: "Title for the signin button"), forState: .Normal)
      } else {
        usernameTextField.text = user.email
      }
    }
  }
  
  @IBAction func signoutTapped(sender: AnyObject) {
    if let user = FIRAuth.auth()?.currentUser {
      if user.anonymous {
        self.performSegueWithIdentifier("createAccountSegue", sender: self)
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
