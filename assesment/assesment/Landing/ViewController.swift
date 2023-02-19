//
//  ViewController.swift
//  assesment
//
//  Created by Fahad on 19/02/2023.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func actionShader(_ sender: Any) {
        print("actionShader")
    }
    
    @IBAction func buttonBezier(_ sender: Any) {
        print("buttonBezier")
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = BezierViewController()
        self.navigationController?.pushViewController(nextViewController, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

