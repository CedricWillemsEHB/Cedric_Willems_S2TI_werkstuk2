//
//  ViewController.swift
//  villoAppIOS
//
//  Created by Anaïs Willems on 1/06/18.
//  Copyright © 2018 Cedric Willems. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let urlVillo = "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale";
    
    var stations = [Station]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stations.removeAll()
        let url=URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Station List"
        fetchJSON()
        
    }
    
    struct  Station: Decodable {
        let name : String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                print(self.stations)
            } catch let jsonErr {
                print("Failed to decode:", jsonErr)
                }
            }
        }.resume()
        
    }
    

    
    func showNames(){
        //looing through all the elements of the array
        for name in stations{
            
            //appending the names to label
            print(name)
        }
    }

}

