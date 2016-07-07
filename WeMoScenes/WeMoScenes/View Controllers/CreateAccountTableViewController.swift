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
      self.showAlert("Error",
                     message: "Please enter an Email Address",
                     dismissButtonTitle: "Dismiss",
                     completionHandler: nil,
                     additionalButtons: nil)
    } else if passwordTextField.text! != confirmPasswordTextfield.text! {
      self.showAlert("Error",
                     message: "Passwords must match, please try again.",
          dismissButtonTitle: "Dismiss",
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
        
        FIRAuth.auth()?.currentUser!.linkWithCredential(credential, completion: { (user, error) in
          self.handleAccountCreation(user, error: error)
                    
          self.dismissViewControllerAnimated(true, completion: nil)
        })
        
      } else {
        // Create account
        FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: self.handleAccountCreation)
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
