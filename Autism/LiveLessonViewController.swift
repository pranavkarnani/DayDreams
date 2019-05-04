//
//  LiveLessonViewController.swift
//  Autism
//
//  Created by Pranav Karnani on 23/03/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import Speech
var flag = 1
class LiveLessonViewController: UIViewController, SFSpeechRecognizerDelegate {
    var prev = ""
    var decode = ""
    
    var x_index = 0
    var y_index = 0
    var first = 0
    @IBOutlet weak var collectionLesson: UICollectionView!
    @IBOutlet weak var dayText: UILabel!
    @IBOutlet weak var dreamsText: UILabel!
    @IBOutlet weak var lessonButton: UIButton!
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        prev = ""
        decode = ""
        super.viewDidLoad()
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.performSegue(withIdentifier: "backToHome", sender: Any?.self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(lessonImages.count == 0) {
            startRecording()
        }
        flag = 1
        dayText.alpha = 1
        dreamsText.alpha = 1
        dayText.textColor = .black
        dreamsText.textColor = .black
        lessonButton.alpha = 1
        lessonButton.layer.borderWidth = 2
        lessonButton.layer.cornerRadius = 8
        lessonButton.titleLabel?.textColor = UIColor(red:255/255, green:36/255, blue:36/255, alpha: 1)
        lessonButton.layer.borderColor = UIColor(red:255/255, green:36/255, blue:36/255, alpha: 1).cgColor
        collectionLesson.reloadData()
    }
    
    @IBAction func endLessonTapped(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            lessonButton.isEnabled = false
            lessonButton.alpha = 0.5
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in

            if result != nil {
                if(flag == 1) {
                    flag = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                        self.decode = result?.bestTranscription.formattedString ?? ""
                        self.triggerSocket(completion: { (stats) in
                            if stats == 1 {
                                flag = 1
                            }
                            else {
                                flag = 1
                            }
                            
                        })
                        self.prev = self.decode
                    })
                }
            }
            else {
    
            }
            
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func triggerSocket(completion : @escaping(Int) -> ()) {
        print(decode)
        DataHandler.shared.getMessageData(text: decode, completion: { (status) in
            if(status == 0) {
                print(lessonImages)
                DispatchQueue.main.async {
                    self.collectionLesson.reloadData()
                    completion(1)
                }
            }
            else {
                completion(0)
            }
        })
    }
}

extension LiveLessonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lessonImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "newLesson", for: indexPath) as! LessonsCollectionViewCell
        DispatchQueue.main.async {
            item.lessonImage.downloaded(from: lessonImages[indexPath.row].imageURL)
        
        item.lessonTitle.text = lessonImages[indexPath.row].desc
        }
        return item
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
