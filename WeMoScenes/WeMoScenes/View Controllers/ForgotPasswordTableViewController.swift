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
    if emailAddressTextField.text!.isEmpty {
      self.showAlert(NSLocalizedString("ErrorTitle", comment: "Title for the error alert"),
							   message: NSLocalizedString("EmailErrorMessage", comment: "Error message when email address is missing"),
                    dismissButtonTitle: NSLocalizedString("DimissTitle", comment: "Title for the dismiss button"),
                     completionHandler: nil,
                     additionalButtons: nil)
    } else {
      FIRAuth.auth()?.sendPasswordResetWithEmail(emailAddressTextField.text!, completion: { (error) in
        if error != nil {
          self.showAlert(NSLocalizedString("ErrorTitle", comment: "Title for the error alert"),
                        message: error!.localizedDescription,
             dismissButtonTitle: NSLocalizedString("DimissTitle", comment: "Title for the dismiss button"),
              completionHandler: {
									[unowned self] in
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                  },
              additionalButtons: nil)
        } else {
          self.showAlert(NSLocalizedString("SuccessTitle", comment: "Title for the success alert"),
                        message: NSLocalizedString("PasswordResetSuccessMessage", comment: "Message shown when password reset email sent."),
             dismissButtonTitle: NSLocalizedString("DimissTitle", comment: "Title for the dismiss button"),
              completionHandler: nil,
              additionalButtons: nil)
        }
      })
    }
  }
}
