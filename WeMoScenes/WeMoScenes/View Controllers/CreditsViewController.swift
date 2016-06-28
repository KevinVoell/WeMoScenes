//
//  CreditsViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/28/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController {

  @IBOutlet weak var creditsTextView: UITextView!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    creditsTextView.setContentOffset(CGPointZero, animated: false)
  }
}
