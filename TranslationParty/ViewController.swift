//
//  ViewController.swift
//  TranslationParty
//
//  Created by Cody LaRont on 11/4/16.
//  Copyright © 2016 Cody LaRont. All rights reserved.
//

import UIKit
import CoreMotion

var translatedString = ""

class ViewController: UIViewController {
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var enteredText: UITextField!
    @IBOutlet weak var changeTextLabel: UIButton!
    
    var motionManager = CMMotionManager()
    
    var sourceLang = ""
    var targetLang = ""
    var nameLang = ""
    var originalString = ""
    var rand = 0
    var count = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        count = 0
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
        
        enteredText.text = ""
        //Set Motion Manager Properties
        motionManager.accelerometerUpdateInterval = 0.2
        
        //Start Recording Data
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.isShaking(accelerometerData!.acceleration)
            if(NSError != nil) {
                print("\(NSError)")
            }
        }
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        resultLabel.text = translatedString
    }
    
    func isShaking(acceleration: CMAcceleration){
        let languages: [String] = ["es", "fr", "zu", "ru", "te", "cy", "vi", "ur", "zh-CN", "pt-BR", "sw", "th", "lt", "la", "kn", "ga"]
        let languageNames: [String] = ["Spanish", "French", "Zulu", "Russian", "Telugu", "Welsh(Cyrmic)", "Vietnamese", "Urdu", "Chinese", "Portuguese", "Swahili", "Thai", "Lithuanian", "Latin", "Kannada", "Irish(Gaelic)"]
        rand = Int(arc4random_uniform(UInt32(languages.count)))
        targetLang = languages[rand]
        nameLang = languageNames[rand]

        //if up and down shake
        if fabs(acceleration.y) > 2 || fabs(acceleration.y) < -2 {
            if count == 0 {
                sourceLang = "en"
                languageLabel.backgroundColor = UIColor.greenColor()
                let baseURL: String = "https://www.googleapis.com/language/translate/v2?key="YOUR-KEY-HERE"&source=\(sourceLang)&target=\(targetLang)&q="
                let originalString: String = enteredText.text!
                let encodedOrString = originalString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                let finalURL = baseURL + encodedOrString!
                print(finalURL)
                let requestURL: NSURL = NSURL(string: finalURL)!
                print("HELLO")
                let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(urlRequest) {
                    (data, response, error) -> Void in
                    
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    if (statusCode == 200) {
                        do{
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                            if let translations = json["data"]!!["translations"]!! as? [[String: AnyObject]] {
                                for translation in translations {
                                    if let translatedText = translation["translatedText"] as? String {
                                        print(translatedText)
                                        print("START")
                                        translatedString = translatedText
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.resultLabel.text = translatedText
                                            })
                                        print("STOP")
                                    }
                                }
                            }
                        }
                        catch {
                            print("Error with Json: \(error)")
                            self.languageLabel.backgroundColor = UIColor.redColor()
                        }
                    }
                }
                print("test1")
                task.resume()
                resultLabel.reloadInputViews()
                print("test2")
                print(translatedString)
                print("test3")
                languageLabel.text = nameLang
                enteredText.enabled = false
                sourceLang = targetLang
                count += 1
            }
            else{
                languageLabel.backgroundColor = UIColor.blueColor()
                let baseURL: String = "https://www.googleapis.com/language/translate/v2?key="YOUR-KEY-HERE"&source=\(sourceLang)&target=\(targetLang)&q="
                let newString: String = translatedString
                let encodedOrString = newString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                let finalURL = baseURL + encodedOrString!
                print(finalURL)
                let requestURL: NSURL = NSURL(string: finalURL)!
                let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(urlRequest) {
                    (data, response, error) -> Void in
                    
                    let httpResponse = response as! NSHTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    if (statusCode == 200) {
                        do{
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                            print(json["data"]!!["translations"]!!)
                            if let translations = json["data"]!!["translations"]!! as? [[String: AnyObject]] {
                                for translation in translations {
                                    if let translatedText = translation["translatedText"] as? String {
                                        print(translatedText)
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.resultLabel.text = translatedText
                                        })
                                        self.languageLabel.text = self.nameLang
                                        translatedString = translatedText
                                    }
                                }
                            }
                        }
                        catch {
                            print("Error with Json: \(error)")
                        }
                    }
                }
                task.resume()
                resultLabel.reloadInputViews()
                languageLabel.text = nameLang
                sourceLang = targetLang
                
            }

        }
        
        //if left and right shake
        if fabs(acceleration.x) > 2.5 || fabs(acceleration.x) < -2.5 {
            //To change text again
            if count > 0 {
                languageLabel.backgroundColor = UIColor.greenColor()
                enteredText.enabled = true
                resultLabel.text = ""
                languageLabel.text = ""
                count = 0
            }
        }
        
        //if back and forth shake
        if fabs(acceleration.z) > 2 || fabs(acceleration.z) < -2 {
            targetLang = "en"
            nameLang = "English"
            languageLabel.backgroundColor = UIColor.yellowColor()
            let baseURL: String = "https://www.googleapis.com/language/translate/v2?key="YOUR-KEY-HERE"&source=\(sourceLang)&target=\(targetLang)&q="
            let newString: String = translatedString
            let encodedOrString = newString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let finalURL = baseURL + encodedOrString!
            print(finalURL)
            let requestURL: NSURL = NSURL(string: finalURL)!
            let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(urlRequest) {
                (data, response, error) -> Void in
                
                let httpResponse = response as! NSHTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                if (statusCode == 200) {
                    do{
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                        print(json["data"]!!["translations"]!!)
                        if let translations = json["data"]!!["translations"]!! as? [[String: AnyObject]] {
                            for translation in translations {
                                if let translatedText = translation["translatedText"] as? String {
                                    print(translatedText)
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.resultLabel.text = translatedText
                                        })
                                    self.languageLabel.text = self.nameLang
                                    translatedString = translatedText
                                }
                            }
                        }
                    }
                    catch {
                        print("Error with Json: \(error)")
                    }
                }
            }
            task.resume()
            resultLabel.reloadInputViews()
            languageLabel.text = nameLang
            sourceLang = targetLang
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

