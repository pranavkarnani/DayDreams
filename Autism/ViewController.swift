//
//  ViewController.swift
//  Autism
//
//  Created by Pranav Karnani on 23/03/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import Speech
import ViewAnimator

var lessons : [String] = ["New Lesson","Independent-India","Avengers Endgame","Democracy","French Revolution"]
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SFSpeechRecognizerDelegate {
    
    private let animations = [AnimationType.from(direction: .left, offset: 30.0),AnimationType.from(direction: .right, offset: 30.0), AnimationType.zoom(scale: 1.3)]
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    @IBOutlet weak var collection: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "lesson", for: indexPath) as! LessonsCollectionViewCell
        if  indexPath.item == 0 {
            item.lessonView.alpha = 0
        }
        else {
            item.lessonImage.image = UIImage(named: lessons[indexPath.item]) ?? nil
            item.lessonTitle.text = lessons[indexPath.item]
        }
        return item
    }
    
    @IBOutlet weak var pinnedView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection?.performBatchUpdates({
            UIView.animate(views: self.collection!.orderedVisibleCells,
                           animations: animations, completion: {
            })
        }, completion: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let cells = collection.visibleCells(in: 1)
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
        UIView.animate(views: cells, animations: [rotateAnimation, zoomAnimation])
        lessonImages = []
    }
    
    override func viewDidLayoutSubviews() {
        pinnedView.layer.cornerRadius = CGFloat(pinnedView.frame.height/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = true
            switch authStatus {
            case .authorized:
                
                isButtonEnabled = true
                if indexPath.item != 0 {
                    DispatchQueue.main.async {
                        lessonImages = []
                    DataHandler.shared.getMessageData(text: lessons[indexPath.row], completion: { (status) in
                        if status == 0 {
                           // lessonImages = []
                            self.performSegue(withIdentifier: "newLesson", sender: Any?.self)
                        }
                    })
                    }
                }
                else {
                    self.performSegue(withIdentifier: "newLesson", sender: Any?.self)
                }
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
        }
    }
}
