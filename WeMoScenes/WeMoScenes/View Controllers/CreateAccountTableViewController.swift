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
    if passwordTextField.text! != confirmPasswordTextfield.text! {
      let alert = UIAlertController(title: "Error", message: "Passwords must match, please try again.", preferredStyle: .Alert)
      
      alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: { 
        self.passwordTextField.text = ""
        self.confirmPasswordTextfield.text = ""
      })
      
    } else {
      FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
        if error != nil {
          let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
          
          alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
          
          self.presentViewController(alert, animated: true, completion: {
            self.passwordTextField.text = ""
            self.confirmPasswordTextfield.text = ""
          })
        } else {
          user?.sendEmailVerificationWithCompletion({ (error) in
            if error != nil {
              self.showAlert("Error", message: error!.localizedDescription)
            } else {
              self.showAlert("Confirm Email", message: "Check your email to confirm your account.")
            }
          })
        }
      })
    }
  }
  
  func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
}
