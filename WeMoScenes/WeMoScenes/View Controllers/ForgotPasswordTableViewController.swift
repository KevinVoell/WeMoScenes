//
//  ForgotPasswordTableViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/25/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordTableViewController: UITableViewController {
  @IBOutlet weak var emailAddressTextField: UITextField!

  @IBAction func resetPasswordTapped(sender: AnyObject) {
    if emailAddressTextField.text == "" {
      let alert = UIAlertController(title: "Error", message: "Please enter your email address.", preferredStyle: .Alert)
      
      alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: {
        
      })
    } else {
      FIRAuth.auth()?.sendPasswordResetWithEmail(emailAddressTextField.text!, completion: { (error) in
        if error != nil {
          let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
          
          alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
          
          self.presentViewController(alert, animated: true, completion: {
            self.dismissViewControllerAnimated(true, completion: nil)
          })
        } else {
          let alert = UIAlertController(title: "Success", message: "Password reset email has been sent.", preferredStyle: .Alert)
          
          alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
          
          self.presentViewController(alert, animated: true, completion: nil)
        }
      })
    }
  }
}
