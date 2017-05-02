//
//  RaccoonViewController.swift
//  Oslo
//
//  Created by Ziyi Zhang on 02/05/2017.
//  Copyright © 2017 Ziyideas. All rights reserved.
//

import UIKit

class RaccoonViewController: UIViewController {
  @IBOutlet var raccoonFaceImageView: UIImageView!
  @IBOutlet var raccoonWordsLabel: UILabel!
  @IBOutlet var hamburgerAndChips: UIStackView!
  @IBOutlet var ChikenAndCoke: UIStackView!
  @IBOutlet var LollipopAndCoffee: UIStackView!

  @IBAction func cancelFed(_ sender: Any) {
  }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
