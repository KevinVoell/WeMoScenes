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
  @IBOutlet weak var anonymousButtonCell: UITableViewCell!
  
  override func viewDidLoad() {
    signinButton.backgroundColor = UIColor.flatGreenColor()
    
    if FIRAuth.auth()?.currentUser != nil {
      anonymousButtonCell.hidden = true
    }
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
        
        }
      })
    }
  }

  /**
    Called when the user taps the signin anonymously button.
    - parameter sender: The button that was tapped
  */
  @IBAction func signinAnonymouslyTapped(sender: AnyObject) {
    let alert = UIAlertController(title: "Confirm", message: "Creating an account allows you to create multiple scenes and share your scenes between multiple devices.\r\n\r\nContinue without creating an account?", preferredStyle: .Alert)

    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

    alert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) in
      FIRAuth.auth()!.signInAnonymouslyWithCompletion({ (user, error) in
        let manager = ApiManager<SceneModel>()
        let scene = SceneModel(withName: "All Switches")
        manager.save(scene)
        })
      })
    )

    self.presentViewController(alert, animated: true, completion: nil)
  }
}
