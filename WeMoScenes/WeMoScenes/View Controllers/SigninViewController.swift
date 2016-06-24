//
//  SigninViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/23/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit
import FirebaseAuth

class SigninViewController: UIViewController {

  @IBAction func signinAnonymouslyTapped(sender: AnyObject) {
    FIRAuth.auth()!.signInAnonymouslyWithCompletion(nil)
  }
}
