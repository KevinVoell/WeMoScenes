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
      self.showAlert(title: "Error", 
                   message: "Please enter your email address and password.",
              dismissTitle: "Dismiss",
         completionHandler: { () in self.passwordTextField.text = "" })
    } else {
      // If we're converting from an anonymous account, save off the anonymous user
      var anonymousUser: FIRUser? = nil
      var anonymousSceneManager: ApiManager<SceneModel>?
      
      if let user = FIRAuth.auth()?.currentUser {
        if user.anonymous {
          anonymousUser = user
          
          // Get any existing scenes the user may have created
          anonymousSceneManager = ApiManager<SceneModel>()
          anonymousSceneManager!.startWatching()
        }
      }
      
      FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
        if error != nil {
          self.showAlert(title: "Error",
                       message: error?.localizedDescription,
             completionHandler: { () in self.passwordTextField.text = "" },
                  dismissTitle: "Dismiss")
          /*
          // TODO: Delete
          let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
          
          alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
          
          self.presentViewController(alert, animated: true, completion: {
            self.passwordTextField.text = ""
          })
          */
        } else {
          if anonymousUser != nil {
            //Save any existing scenes under the new user
            let newSceneManager = ApiManager<SceneModel>()
            for scene in anonymousSceneManager!.items {
              // TODO: Check for "All switches"
              newSceneManager.save(scene)
            }
            
            // Delete the anonymous users account
            anonymousUser?.deleteWithCompletion(nil)
          }
          
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      })
    }
  }

  /**
    Called when the user taps the signin anonymously button.
    - parameter sender: The button that was tapped
  */
  @IBAction func signinAnonymouslyTapped(sender: AnyObject) {
    self.showAlert(title: "Confirm", 
                 message: "Creating an account allows you to create multiple scenes and share your scenes between multiple devices.\r\n\r\nContinue without creating an account?",
            dismissTitle: "Cancel",
   additionalButtonTitle: "Continue",
 additionalButtonHandler: { () in       
              FIRAuth.auth()!.signInAnonymouslyWithCompletion({ (user, error) in
              let manager = ApiManager<SceneModel>()
              let scene = SceneModel(withName: "All Switches")
              manager.save(scene)
              })
            })
          }
    /*
    // TODO: Delete
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
    */
  }
}
