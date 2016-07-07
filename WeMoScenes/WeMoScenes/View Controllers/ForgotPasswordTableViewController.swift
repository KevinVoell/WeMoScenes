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
      self.showAlert("Error",
                     message: "Please enter your email address.",
                     dismissButtonTitle: "Dismiss",
                     completionHandler: nil,
                     additionalButtons: nil)
    } else {
      FIRAuth.auth()?.sendPasswordResetWithEmail(emailAddressTextField.text!, completion: { (error) in
        if error != nil {
          self.showAlert("Error",
                        message: error!.localizedDescription,
             dismissButtonTitle: "Dismiss",
              completionHandler: {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                  },
              additionalButtons: nil)
        } else {
          self.showAlert("Success",
                        message: "Password reset email has been sent.",
             dismissButtonTitle: "Dismiss",
              completionHandler: nil,
              additionalButtons: nil)
        }
      })
    }
  }
}
