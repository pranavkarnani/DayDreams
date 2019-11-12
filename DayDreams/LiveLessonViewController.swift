//
//  ViewController.swift
//  DayDreams
//
//  Created by Pranav Karnani on 02/09/19.
//  Copyright © 2019 Pranav Karnani. All rights reserved.
//

import UIKit
import Speech
import Kingfisher

class LiveLessonViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var collectionViewA: UICollectionView!
    
    var isAuthorized: Bool = false
    var lessonImages: Set<String> = []
    var pinterestItems : [String] = []
    var imageIndex = 0

    @IBOutlet weak var microphoneButton: UIButton!
    
    var prevCount = 0
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
        speechRecognizer.delegate = self
        
        collectionViewA.delegate = self
        collectionViewA.dataSource = self
        
        if importedText != "" {
            streamData(text: importedText)
        }
    }
    
    @IBAction func backBttnTapped(_ sender: Any) {
           dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if self.isAuthorized {
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                microphoneButton.isEnabled = false
                microphoneButton.setTitle("Start Recording", for: .normal)
            } else {
                startRecording()
                microphoneButton.setTitle("Stop Recording", for: .normal)
            }
        } else {
            self.showAlert(title: "Error", message: "Unaotherized request")
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
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
        
        speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if result != nil {
                let spokenText = result?.bestTranscription.formattedString
                let words = spokenText?.components(separatedBy: .whitespaces)
                if (words?.count ?? 2) % 5 == 0 {
                    print(spokenText)
                    self.streamData(text: spokenText!)
                }
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                let spokenText = result?.bestTranscription.formattedString
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.microphoneButton.isEnabled = true
                self.streamData(text: spokenText!)
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
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    func requestAuthorization() {
        DispatchQueue.main.async {
            SFSpeechRecognizer.requestAuthorization { (authStatus) in
                switch authStatus {
                case .authorized:
                    self.isAuthorized = true
                @unknown default:
                    self.isAuthorized = false
                }
            }
        }
    }
    
    func updateCollectionView() {
        pinterestItems = []
        for item in lessonImages {
            pinterestItems.append(item)
        }
        collectionViewA.reloadData()
    }
}

extension LiveLessonViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let x = Double(pinterestItems.count)
        let val = (ceil((2/3)*x))
        return val.toInt() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if imageIndex >= pinterestItems.count {
            imageIndex = imageIndex % pinterestItems.count
        }
        if indexPath.item % 2 == 0 {
            let cellA = collectionView.dequeueReusableCell(withReuseIdentifier: "lesson1", for: indexPath) as! LessonACollectionViewCell
            cellA.lessonThumbnail.kf.setImage(with: URL(string: pinterestItems[imageIndex]))
            imageIndex += 1
            return cellA
        }
        else {
             let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: "lesson2", for: indexPath) as! LessonBCollectionViewCell
            cellB.lessonThumbnailA.kf.setImage(with: URL(string: pinterestItems[imageIndex]))
            imageIndex += 1
            if imageIndex < pinterestItems.count {
                cellB.lessonThumbnailB.kf.setImage(with: URL(string: pinterestItems[imageIndex]))
                imageIndex += 1
            }
            return cellB
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width_B = collectionView.frame.width - collectionViewA.frame.width/2.1 - 20
        if indexPath.item % 2 == 0 {
            return CGSize(width: collectionViewA.frame.width/2.1, height: collectionViewA.frame.height)
        } else {
            return CGSize(width: width_B, height: collectionViewA.frame.height)
        }
    }
    
    func streamData(text : String) {
        DataHandler.shared.streamSocketData(text: text) { (data) in
            print("data",data)
            for item in data {
                self.lessonImages.insert(item.imageURL)
            }
            if self.prevCount != self.lessonImages.count {
                self.updateCollectionView()
                self.prevCount = self.lessonImages.count
            }
            self.updateCollectionView()
        }
    }
}

extension Double {
    func toInt() -> Int? {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}
