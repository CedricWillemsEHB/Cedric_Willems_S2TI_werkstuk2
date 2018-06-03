//
//  ViewController.swift
//  villoAppIOS
//
//  Created by Anaïs Willems on 1/06/18.
//  Copyright © 2018 Cedric Willems. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let urlVillo = "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale";
    
    var stations = [Station]()
    
    let manager = CLLocationManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var hellotxt: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    
    struct  Station: Decodable {
        var name : String
        let number : Int
        let address : String
        let position : Position
        let banking : Bool
        let bonus : Bool
        let status : String
        let contract_name : String
        let bike_stands : Int
        let available_bike_stands : Int
        let available_bikes : Int
        let last_update : Int64
        
        init(name : String, number : Int, address : String, position : Position, banking : Bool, bonus : Bool, status : String, contract_name : String, bike_stands : Int, available_bike_stands : Int, available_bikes : Int, last_update : Int64) {
            self.name = name
            self.number = number
            self.address = address
            self.position = position
            self.banking = banking
            self.bonus = bonus
            self.status = status
            self.contract_name = contract_name
            self.bike_stands = bike_stands
            self.available_bike_stands = available_bike_stands
            self.available_bikes = available_bikes
            self.last_update = last_update
        }
    }
    
    struct Position: Decodable {
        let lat : Double
        let lng : Double
        
        init(lat : Double, lng : Double) {
            self.lat = lat
            self.lng = lng
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        DispatchQueue.main.async {
            self.deleteAllDataFromCoreData()
        }
        requestJSON()
        requestCoreData()
        setInMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setInMap(){
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        for station in stations {
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            let location = CLLocationCoordinate2D(latitude: station.position.lat, longitude: station.position.lng)
            let myAnnotation = LocatieAnnotation(coordinate: location)
            map.addAnnotation(myAnnotation)
        }
    }
    
    func deleteAllDataFromCoreData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "VilloStation")
        
        //let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do
        {
            let verwijderStations = try context.fetch(request) as! [VilloStation]
            for verwijderStation in verwijderStations {
                context.delete(verwijderStation)
                try context.save()
            }
        }
        catch
        {
            //TODO error
            print("Error from delete")
        }
    }
    
    func requestCoreData() {
        //TODO
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "VilloStation")
        
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(request)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    let positionOne = Position(lat: result.value(forKey: "lat") as! Double, lng: result.value(forKey: "lng") as! Double)
                    let stationOne = Station(name: result.value(forKey: "name") as! String, number: result.value(forKey: "number")  as! Int, address: result.value(forKey: "address") as! String, position: positionOne , banking: (result.value(forKey: "banking") != nil), bonus: (result.value(forKey: "bonus") != nil), status: result.value(forKey: "status") as! String, contract_name: result.value(forKey: "contract_name") as! String, bike_stands: result.value(forKey: "bike_stands") as! Int, available_bike_stands: result.value(forKey: "available_bike_stands") as! Int, available_bikes: result.value(forKey: "available_bikes") as! Int, last_update: result.value(forKey: "last_update") as! Int64)
                    self.stations.append(stationOne)
                    print(stationOne)
                    /*
                    if let stationName = result.value(forKey: "name") as? String
                    {
                        print(stationName)
                    }
                    if let stationLat = result.value(forKey: "lat") as? Double
                    {
                        print(stationLat)
                    }
                    */
                    
                }
                print(results.count)
            }
        }
        catch
        {
            //TODO error
        }
        
       
    }
    
    func requestJSON() {
        stations.removeAll()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Station List"
        fetchJSON()
    }
    
    fileprivate func fetchJSON() {
        guard let urlJSON = URL(string: urlVillo) else { return }
        URLSession.shared.dataTask(with: urlJSON) { (data, _, err) in
            DispatchQueue.main.async {
            if let err = err {
                print("Failed to get data from url:", err)
                return
            }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                self.stations = try decoder.decode([Station].self, from: data)
                //TODO

                
                
                for station in self.stations {
                 
                    DispatchQueue.main.async {
                        self.setVilloIntoCoreData(station: station)
                    }
                }
                print("core data saved")
                //print(self.stations)
            } catch let jsonErr {
                print("Failed to decode:", jsonErr)
                }
            }
        }.resume()
        
        
    }
    
    func setVilloIntoCoreData(station: Station){
        //TODO
        let newVilloStation = NSEntityDescription.insertNewObject(forEntityName: "VilloStation", into: self.context)
        newVilloStation.setValue(station.number, forKey: "number")
        newVilloStation.setValue(station.name, forKey: "name")
        newVilloStation.setValue(station.address, forKey: "address")
        newVilloStation.setValue(station.position.lat, forKey: "lat")
        newVilloStation.setValue(station.position.lng, forKey: "lng")
        newVilloStation.setValue(station.banking, forKey: "banking")
        newVilloStation.setValue(station.bonus, forKey: "bonus")
        newVilloStation.setValue(station.status, forKey: "status")
        newVilloStation.setValue(station.contract_name, forKey: "contract_name")
        newVilloStation.setValue(station.bike_stands, forKey: "bike_stands")
        newVilloStation.setValue(station.available_bike_stands, forKey: "available_bike_stands")
        newVilloStation.setValue(station.available_bikes, forKey: "available_bikes")
        newVilloStation.setValue(station.last_update, forKey: "last_update")
        do{
            try self.context.save()
            //print(station.name)
        }
        catch{
            //TODO Error
        }
    }
    
    func showNames(){
        //looing through all the elements of the array
        for name in stations{
            
            //appending the names to label
            print(name)
        }
    }

}

