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
      self.showAlert("Error",
                     message: "Please enter your email address and password.",
          dismissButtonTitle: "Dismiss",
           completionHandler: { () in self.passwordTextField.text = "" },
           additionalButtons: nil)
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
          self.showAlert("Error",
                       message: error!.localizedDescription,
            dismissButtonTitle: "Dismiss",
             completionHandler: { () in self.passwordTextField.text = "" },
             additionalButtons: nil)
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
    self.showAlert(NSLocalizedString("ConfirmTitle", comment: "Confirm"),
                 message: NSLocalizedString("AnonymousAccountMessage", comment: "Shows when creating new account"),
            dismissButtonTitle: NSLocalizedString("CancelTitle", comment: "Cancel title"),
            completionHandler: nil,
            additionalButtons: [(title: NSLocalizedString("ContinueTitle", comment: "Continue title"), handler: { (UIAlertAction) in
              FIRAuth.auth()!.signInAnonymouslyWithCompletion({ (user, error) in
                let manager = ApiManager<SceneModel>()
                let scene = SceneModel(withName: "All Switches")
                manager.save(scene)
              })
            })
      ])
  }
}
