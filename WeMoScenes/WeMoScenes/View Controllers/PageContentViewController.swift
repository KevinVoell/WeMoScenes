//
//  PageContentViewController.swift
//  WeMoScenes
//
//  Created by Kevin Voell on 6/4/16.
//  Copyright © 2016 Kevin Voell. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {
  
  @IBOutlet weak var onButton: UIButton!
  @IBOutlet weak var offButton: UIButton!
  
  internal var pageIndex: Int?
  internal var sceneName: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  @IBAction func onButtonTapped(sender: AnyObject) {
    let alertController = UIAlertController.init(title: "Button Tapped", message: "You tapped the on button", preferredStyle: UIAlertControllerStyle.Alert)
    
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }

  @IBAction func offButtonTapped(sender: AnyObject) {
    let alertController = UIAlertController.init(title: "Button Tapped", message: "You tapped the off button", preferredStyle: UIAlertControllerStyle.Alert)
    
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
