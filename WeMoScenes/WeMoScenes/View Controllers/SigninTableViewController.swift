//
//  SigninViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/23/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import FirebaseAuth

class SigninTableViewController: UITableViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var signinButton: UIButton!
  @IBOutlet weak var createAccountButton: UIButton!
  
  override func viewDidLoad() {
    signinButton.backgroundColor = UIColor.flatGreenColor()
  }
  
  @IBAction func signinButtonTapped(sender: AnyObject) {
    if emailTextField.text == "" || passwordTextField.text == "" {
      let alert = UIAlertController(title: "Error", message: "Please enter your email address and password.", preferredStyle: .Alert)
      
      alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
      
      self.presentViewController(alert, animated: true, completion: {
        self.passwordTextField.text = ""
      })
    } else {
      FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
        if error != nil {
          let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
          
          alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
          
          self.presentViewController(alert, animated: true, completion: {
            self.passwordTextField.text = ""
          })
        } else {
          
          if !user!.emailVerified {
            let alert = UIAlertController(title: "Email Not Verified", message: "Please verify your email address.", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Resend", style: .Default, handler: { (action) in
              user!.sendEmailVerificationWithCompletion({ (error) in
                let alert2 = UIAlertController(title: "Verify Email", message: "Check your email to confirm your account.", preferredStyle: .Alert)
                
                alert2.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                
                self.presentViewController(alert2, animated: true, completion: nil)
              })
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
          }
        }
      })
    }
  }

  /**
    Called when the user taps the signin anonymously button.
    - parameter sender: The button that was tapped
  */
  @IBAction func signinAnonymouslyTapped(sender: AnyObject) {
    FIRAuth.auth()!.signInAnonymouslyWithCompletion(nil)
  }
}
