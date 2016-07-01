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
    if emailTextField.text! == "" {
      self.showAlert("Error", message: "Please enter an Email Address")
    } else if passwordTextField.text! != confirmPasswordTextfield.text! {
      let alert = UIAlertController(title: "Error", message: "Passwords must match, please try again.", preferredStyle: .Alert)
      
      alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: { 
        self.passwordTextField.text = ""
        self.confirmPasswordTextfield.text = ""
      })
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
      let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
      
      alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: {
        self.passwordTextField.text = ""
        self.confirmPasswordTextfield.text = ""
      })
    } else {

    }
  }
  
  func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    
    alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
}
