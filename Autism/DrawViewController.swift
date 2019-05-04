//
//  ViewController.swift
//  PageView
//
//  Created by Aritro Paul on 23/03/19.
//  Copyright © 2019 Aritropaul. All rights reserved.
//

import UIKit
import Sketch

class DrawViewController: UIViewController {
    
    @IBOutlet weak var sketchPad: SketchView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func penTapped(_ sender: Any) {
        sketchPad.drawTool = .pen
    }
    @IBAction func undoTapped(_ sender: Any) {
        sketchPad.undo()
    }
    @IBAction func redoTapped(_ sender: Any) {
        sketchPad.redo()
    }
    @IBAction func eraserTapped(_ sender: Any) {
        sketchPad.drawTool = .eraser
    }
    @IBAction func clearTapped(_ sender: Any) {
        sketchPad.clear()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.performSegue(withIdentifier: "back", sender: Any?.self)
    }
}

