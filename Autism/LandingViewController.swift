//
//  LandingViewController.swift
//  Autism
//
//  Created by Pranav Karnani on 23/03/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.performSegue(withIdentifier: "dashboard", sender: Any?.self)
    }
}
