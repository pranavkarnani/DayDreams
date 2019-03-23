//
//  LandingViewController.swift
//  Autism
//
//  Created by Pranav Karnani on 23/03/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import SwiftVideoBackground

class LandingViewController: UIViewController {

    @IBAction func start(_ sender: Any) {
        self.performSegue(withIdentifier: "dashboard", sender: Any?.self)
    }
    
   
    @IBOutlet weak var startBttn: UIButton!
    
    let overlayView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startBttn.isEnabled = false
        startBttn.alpha = 0.5
        try? VideoBackground.shared.play(view: view, videoName: "Final Video", videoType: "mp4")
        overlayView.frame = view.frame
        overlayView.backgroundColor = .white
        overlayView.alpha = 0.4
        view.addSubview(overlayView)
        view.sendSubviewToBack(overlayView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DataHandler.shared.connectSocket { (status) in
            if(status) {
                self.startBttn.alpha = 1.0
                self.startBttn.isEnabled = true
            }
        } 
    }
    
    override func viewDidLayoutSubviews() {
        startBttn.layer.cornerRadius = 15
    }
}
