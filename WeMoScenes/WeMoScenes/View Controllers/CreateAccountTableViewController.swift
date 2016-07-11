//
//  CreateAccountViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/24/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateAccountTableViewController: UITableViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var confirmPasswordTextfield: UITextField!
  
  @IBAction func createAccountTapped(sender: AnyObject) {
    if emailTextField.text!.isEmpty {
      self.showAlert(NSLocalizedString("ErrorTitle", comment: "Title for the error alert"),
                     message: NSLocalizedString("EmailErrorMessage", comment: "Error message when email address is missing"),
                     dismissButtonTitle: NSLocalizedString("DimissTitle", comment: "Title for the dismiss button"),
                     completionHandler: nil,
                     additionalButtons: nil)
    } else if passwordTextField.text! != confirmPasswordTextfield.text!
              || passwordTextField.text!.isEmpty {
      self.showAlert(NSLocalizedString("ErrorTitle", comment: "Title for the error alert"),
                     message: NSLocalizedString("PasswordMismatchErrorMessage", comment: "Error message when passwords don't match"),
          dismissButtonTitle: NSLocalizedString("DimissTitle", comment: "Title for the dismiss button"),
           completionHandler: {
								[unowned self] in
								self.passwordTextField.text = ""
								self.confirmPasswordTextfield.text = ""
							  },
           additionalButtons: nil)
    } else {
      if FIRAuth.auth()?.currentUser != nil && (FIRAuth.auth()?.currentUser!.anonymous)! {
        // Link account
        let credential = FIREmailPasswordAuthProvider.credentialWithEmail(emailTextField.text!, password: passwordTextField.text!)
        
        FIRAuth.auth()?.currentUser!.linkWithCredential(credential, completion: { 
					[unowned self]
          (user, error) in
          self.handleAccountCreation(user, error: error)      
          self.dismissViewControllerAnimated(true, completion: nil)
        })
        
      } else {
        // Create account
        FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, 
											password: passwordTextField.text!, 
										  completion: self.handleAccountCreation)
      }
    }
  }
  
  func handleAccountCreation(user: FIRUser?, error: NSError?) {
    if error != nil {
      self.showAlert("Error",
                     message: error!.localizedDescription,
          dismissButtonTitle: "Dismiss",
           completionHandler: {
                                [unowned self] in
                                self.passwordTextField.text = ""
                                self.confirmPasswordTextfield.text = ""
                               },
           additionalButtons: nil)
    }
  }
}
