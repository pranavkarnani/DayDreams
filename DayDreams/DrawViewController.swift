//
//  DrawViewController.swift
//  DayDreams
//
//  Created by Pranav Karnani on 02/09/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import Sketch

class DrawViewController: UIViewController {

    @IBOutlet weak var sketchView: SketchView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(sketchView)
        sketchView.layer.borderWidth = 2
        sketchView.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func undoBttnTapped(_ sender: Any) {
        tapUndoButton()
    }
    @IBAction func paletteBttnTapped(_ sender: Any) {
        tapPaletteButton()
    }
    @IBAction func eraserBttnTapped(_ sender: Any) {
        tapEraserButton()
    }
    @IBAction func penBttnTapped(_ sender: Any) {
        tapPenButton()
    }
    @IBAction func backBttnTapped(_ sender: Any) {
           dismiss(animated: true, completion: nil)
    }
    
    func tapPenButton() {
        sketchView.drawTool = .pen
    }

    func tapEraserButton() {
        sketchView.drawTool = .eraser
    }
    
    func tapUndoButton() {
        sketchView.undo()
    }
    
    func tapPaletteButton() {
        
        let blackAction = UIAlertAction(title: "Black", style: .default) { _ in
            self.sketchView.lineColor = .black
        }
        let blueAction = UIAlertAction(title: "Blue", style: .default) { _ in
            self.sketchView.lineColor = .blue
        }
        let redAction = UIAlertAction(title: "Red", style: .default) { _ in
            self.sketchView.lineColor = .red
        }
        let orangeAction = UIAlertAction(title: "Orange", style: .default) { _ in
            self.sketchView.lineColor = .orange
        }
        let yellowAction = UIAlertAction(title: "Yellow", style: .default) { _ in
                   self.sketchView.lineColor = .yellow
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        let alertController = UIAlertController(title: "Please select a color", message: nil, preferredStyle: .alert)
        alertController.addAction(blackAction)
        alertController.addAction(blueAction)
        alertController.addAction(redAction)
        alertController.addAction(orangeAction)
        alertController.addAction(yellowAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
}
