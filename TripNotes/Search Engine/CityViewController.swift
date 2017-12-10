//
//  CityViewController.swift
//  TripNotes
//
//  Created by John Park on 12/6/17.
//  Copyright © 2017 John Park. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

protocol CityProtocol {
    func didPressSaveCity(city: City)
}

class CityViewController: UIViewController {
    
    // MARK: Spacing
    let padding1: CGFloat = 75
    let padding2: CGFloat = 8
    let padding3: CGFloat = 12
    let fontSize: CGFloat = 20
    
    // MARK: UI
    var saveButton: UIBarButtonItem!
    var label: UILabel!
    var noteLabel: UILabel!
    var userNotes: UITextView!
    var timeLabel: UILabel!
    
    // MARK: Data
    var city: City!
    
    // MARK: Delegation
    var cityDelegate: CityProtocol!
    
    // MARK: Init
    init(city: City) {
        super.init(nibName: nil, bundle: nil)
        self.city = city
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        view.backgroundColor = .white
        
        // UI setup
        setUpSaveButton()
        setUpLabels()
        setUpNotes()
        
        // title
        let str: String = label.text!
        if let range = str.range(of: ",") {
            title = String(str[..<range.lowerBound]).uppercased()
        } else {
            title = str.uppercased()
        }
        
        // Network
        setUpTimeLabel()
        getForecast(input: title!)
    }
    
    // MARK: saveButton setup
    func setUpSaveButton() {
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveCity))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func saveCity() {
        city.notes = userNotes.text
        cityDelegate.didPressSaveCity(city: city)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: labels setup
    func setUpLabels() {
        label = UILabel(frame: CGRect(x: 0, y: padding1, width: view.frame.width, height: fontSize + 4))
        label.textAlignment = .center
        label.text = city.label
        label.font = UIFont(name: "Futura-CondensedExtraBold", size: fontSize)
        view.addSubview(label)
    }
    
    // MARK: noteLabel and userNotes setup
    func setUpNotes() {
        noteLabel = UILabel(frame: CGRect(x: padding2, y: (view.center.y + padding1 * 3.3) - fontSize, width: view.frame.width - padding2 * 2, height: fontSize + 2))
        noteLabel.text = "Notes:"
        view.addSubview(noteLabel)
        
        userNotes = UITextView(frame: CGRect(x: padding2, y: view.center.y + padding1 * 3.3, width: view.frame.width - padding2 * 2, height: padding1 * 1.5))
        userNotes.font = UIFont(name: "AmericanTypewriter ", size: 18.0)
        userNotes.textColor = .blue
        userNotes.text = city.notes
        view.addSubview(userNotes)
    }
    
    // MARK: timeLabel setup
    func setUpTimeLabel() {
        timeLabel = UILabel(frame: CGRect(x: padding3, y: padding1 + fontSize + padding3, width: view.frame.width - padding3 * 2, height: fontSize / 1.2 + 2))
        timeLabel.text = "Searching..."
        timeLabel.font = UIFont(name: "Futura-CondensedExtraBold", size: fontSize / 1.5)
        view.addSubview(timeLabel)
    }
    
    // MARK: Required Swift function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //FIX - USE NETWORK MANAGER INSTEAD
    func getForecast(input: String) {
        let apixiAPI = "https://api.apixu.com/v1/forecast.json?"
        let space = "%20"
        let apixiKey = "key=04bbf229c12940a49e8173840170812"
        let input = "&q=" + input.replacingOccurrences(of: " ", with: space)
        let url = apixiAPI + apixiKey + input
        Alamofire.request(url, method: .get)
            .validate()
            .responseJSON { response in
                switch response.result {
                case let .success(data):
                    let json = JSON(data)
                    if let time = json["location"]["localtime"].string {
                        self.city.time = "Time: " + time
                        var counter: Int = 0
                        while counter < 24 {
                            let hour: String = (json["forecast"]["forecastday"][0]["hour"].array?[counter]["time"].string)!
                            let hourTemp: Int = (json["forecast"]["forecastday"][0]["hour"].array?[counter]["temp_f"].int)!
                            let hourRain: String = (json["forecast"]["forecastday"][0]["hour"].array?[counter]["chance_of_rain"].string)!
                            let hourText: String = (json["forecast"]["forecastday"][0]["hour"].array?[counter]["condition"]["text"].string)!
                            let hourImg: String =  (json["forecast"]["forecastday"][0]["hour"].array?[counter]["condition"]["icon"].string)!
                            self.city.weather.append(Weather(hour: hour, hourTemp: hourTemp, hourRain: hourRain, hourText: hourText, hourImg: hourImg))
                            counter += 1
                        }
                    } else {
                        self.city.time = "Time: N/A"
//                        self.city.weather.append(Weather(hour: "N/A", hourTemp: 0, hourRain: "N/A", hourText: "N/A", hourImg: "N/A"))
                    }
                    self.timeLabel.text = self.city.time
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
}
