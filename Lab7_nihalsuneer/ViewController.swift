//
//  ViewController.swift
//  Lab7_nihalsuneer
//
//  Created by user235383 on 11/8/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var cSpeed: UILabel!
    
    @IBOutlet weak var mSpeed: UILabel!
    
    @IBOutlet weak var aSpeed: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var mAcceleration: UILabel!
    
    @IBOutlet weak var overSpeed: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tripIndicator: UIButton!
    
    
    @IBOutlet weak var endMap: UIButton!
    
    
        var startTime: Date?
        var tripProgress = false
        var mapcurrentSpeed: CLLocationSpeed = 0.0
        var mapmaxSpeed: CLLocationSpeed = 0.0
        var mapDistance: CLLocationDistance = 0.0
        var mapmaxAcceleration: Double = 0.0
        let mapRegion: Double = 5000
        
        var mapManager = CLLocationManager ()
        var locations: [CLLocation] = []
        var previousSpeedLimit = 0.0
        var overspeedFlag = false
    
    //Map Visibility
    
          override func viewDidAppear(_ animated: Bool) {
          initialValues()
          mapManager.delegate = self
          mapView.delegate = self
          mapManager.desiredAccuracy = kCLLocationAccuracyBest
          mapManager.requestWhenInUseAuthorization()
          mapManager.startUpdatingLocation()
          mapView.showsUserLocation = true
      }
    func initialValues(){
           cSpeed.text = "0 km/h"
           mSpeed.text = "0 km/h"
           aSpeed.text = "0 km/h"
           distance.text = "0 km"
           mAcceleration.text = "0 m/s^2"
           endMap.isEnabled = false
           tripIndicator.backgroundColor = UIColor.lightGray
           overSpeed.backgroundColor = UIColor.clear
           locations.removeAll()
           tripProgress = false
           mapcurrentSpeed = 0.0
           mapmaxSpeed = 0.0
           mapDistance = 0.0
           mapmaxAcceleration = 0.0
           previousSpeedLimit = 0.0
           overspeedFlag = false

       }
    @IBAction func startButton(_ sender: Any) {
        startTime = Date()
                initialValues()
                mapManager.startUpdatingLocation()
                tripIndicator.backgroundColor = UIColor.green
                endMap.isEnabled = true
                focusontheUser()
                tripProgress = true
    }
    
    
    @IBAction func endButton(_ sender: Any) {
        tripProgress = false
               mapManager.stopUpdatingLocation()
               tripIndicator.backgroundColor = UIColor.gray
               endMap.isEnabled = false
               cSpeed.text = "0 km/h"
               overSpeed.backgroundColor = UIColor.clear
               print("Max speed == \(mapmaxSpeed)")
               let avg = aSpeed.text!
               print("Average speed == \(avg)")
               let dist = distance.text!
               print("Distance Travelled = \(dist)")
               if !overspeedFlag {
                   print("Distance Travelled Before Exceeding Speed Limit == \(dist)")
               }else{
                   print("Distance Travelled Before Exceeding Speed Limit == \(previousSpeedLimit)")
               }
    }
    
    func focusontheUser() {
          if let location = mapManager.location?.coordinate {
              let region = MKCoordinateRegion.init(center: location, latitudinalMeters: mapRegion, longitudinalMeters: mapRegion)
              mapView.setRegion(region, animated: true)
          }
      }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           if(tripProgress){
               guard let location = locations.last else { return }
               let centre = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
               let region = MKCoordinateRegion.init(center: centre, latitudinalMeters: mapRegion, longitudinalMeters: mapRegion)
               mapView.setRegion(region, animated: true)
               calculateData(newLocation: location)
               updateText()
               
           }
       }
    
    func updateText() {
            
            cSpeed.text = String(format: "%.2f km/h", mapcurrentSpeed)
            mSpeed.text = String(format: "%.2f km/h", mapmaxSpeed)
            // speed conversion
            if locations.count > 1 {
                let speedsArray = locations.map { $0.speed * 3.6 }
                let averageSpeed = speedsArray.reduce(0, +) / Double(speedsArray.count)
                aSpeed.text = String(format: "%.2f km/h", averageSpeed)
            } else {
                aSpeed.text = "0 km/h"
            }
            
            distance.text = String(format: "%.2f km", mapDistance / 1000)
            mAcceleration.text = String(format: "%.2f m/s^2", mapmaxAcceleration)
            
            if mapcurrentSpeed > 115 {
                if !overspeedFlag{
                    previousSpeedLimit = mapDistance/1000
                    overspeedFlag = true
                    }
                overSpeed.backgroundColor = UIColor.red
            } else {
                overSpeed.backgroundColor = UIColor.clear
            }
            print("Current speed == \(mapcurrentSpeed)")
        }
        
        func calculateData(newLocation: CLLocation) {
            if let startTime = startTime {
                let currentTime = Date()
                let timeInterval = currentTime.timeIntervalSince(startTime)
                
                let speed = newLocation.speed * 3.6
                mapcurrentSpeed = speed
                
                if speed > mapmaxSpeed {
                    mapmaxSpeed = speed
                }
                locations.append(newLocation)
                
                // Calculate the distance
                if locations.count > 1 {
                    mapDistance += newLocation.distance(from: locations[locations.count - 2])
                }
                
                // acceleration
                let previousSpeed = locations.count > 1 ? locations[locations.count - 2].speed * 3.6 : 0.0
                let acceleration = abs((speed - previousSpeed) / timeInterval)
                if acceleration > mapmaxAcceleration {
                    mapmaxAcceleration = acceleration
                }
            }
            
        }
    
}

