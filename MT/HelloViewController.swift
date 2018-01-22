//
//  HelloViewController.swift
//  MT
//
//  Created by ILYA Abramovich on 22.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import UIKit

class HelloViewController: UIViewController {

    @IBOutlet weak var mask: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = mask.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mask.addSubview(blurEffectView)
        
        
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "sawHelloVC")
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
