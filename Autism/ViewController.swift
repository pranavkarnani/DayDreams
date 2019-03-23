//
//  ViewController.swift
//  Autism
//
//  Created by Pranav Karnani on 23/03/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import Speech

var lessons : [String] = ["New Lesson","Space","Space","Space"]
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SFSpeechRecognizerDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "lesson", for: indexPath) as! LessonsCollectionViewCell
        if  indexPath.item == 0 {
            item.lessonView.alpha = 0
        }
        else {
            item.lessonImage.image = UIImage(named: lessons[indexPath.item])
            item.lessonTitle.text = lessons[indexPath.item]
            item.lessonImage.contentMode = .scaleToFill
        }
        return item
    }
    
    
    
    @IBOutlet weak var pinnedView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
                self.performSegue(withIdentifier: "newLesson", sender: Any?.self)
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
