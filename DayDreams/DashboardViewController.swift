//
//  DashboardViewController.swift
//  DayDreams
//
//  Created by Pranav Karnani on 02/11/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import Speech

var importedText = ""

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var newLessonBttn: UIButton!
    var lessonThumbnail : [String] = ["Independent-India","Avengers Endgame","Democracy","French Revolution"]
    var lessons : [String] = ["Independent-India","Avengers Endgame","Democracy","French Revolution"]
    
    @IBOutlet weak var collection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            
        }
        collection.dataSource = self
        collection.delegate = self
    }

    @IBAction func newLessonBttnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "new_lesson", sender: Any?.self)
    }
    
    @IBAction func drawBttnTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "draw", sender: Any?.self)
    }
}

extension DashboardViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "lesson", for: indexPath) as! LessonsCollectionViewCell
        item.lessonImage.image = UIImage(named: lessonThumbnail[indexPath.item]) ?? nil
        item.lessonTitle.text = lessons[indexPath.item]
        item.lessonTitle.layer.cornerRadius = CGFloat(8)
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: newLessonBttn.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        importedText = lessons[indexPath.item]
        self.performSegue(withIdentifier: "new_lesson", sender: Any?.self)
    }
}


extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let bttn = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(bttn)
        present(alert, animated: true, completion: nil)
    }
}
