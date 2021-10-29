//
//  SearchCityViewController.swift
//  Weather
//
//  Created by Ashish Ashish on 10/28/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import RealmSwift


class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
   
    let arr = ["Seattle WA, USA", "Seaside CA, USA"]
    
    var arrCityInfo : [CityInfo] = [CityInfo]()

    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            return
        }
        getCitiesFromSearch(searchText)

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // You will change this to arrCityInfo.count
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let curCity = arrCityInfo[indexPath.row]
        //cell.textLabel?.text = arr[indexPath.row] // You will change this to getr values from arrCityinfo and assign text
        cell.textLabel?.text = String(format: "%@ %@, %@", curCity.localizedName, curCity.administrativeID, curCity.countryLocalizedName)
        
        return cell
    }
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    
    func getCitiesFromSearch(_ searchText : String) {
        // Network call from there
        
        let url = getSearchURL(searchText)
        
    
        AF.request(url).responseJSON { response in
            
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
            
            
            // You will receive JSON array
            // Parse the JSON array
            // Add values in arrCityInfo
            // Reload table with the values
            let json = JSON( response.data!)
            self.arrCityInfo.removeAll()
            for item in json.arrayValue {
                
                let ci = CityInfo()
                
                ci.key = item["Key"].stringValue
                ci.type = item["Type"].stringValue
                ci.localizedName = item["LocalizedName"].stringValue
                ci.countryLocalizedName = item["Country"]["LocalizedName"].stringValue
                ci.administrativeID = item["AdministrativeArea"]["ID"].stringValue
                
                self.arrCityInfo.append(ci)
                
                print(ci)
            }

            self.tblView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // You will get the Index of the city info from here and then add it into the realm Database
        // Once the city is added in the realm DB pop the navigation view controller
        let city = arrCityInfo[indexPath.row]
        print(city)
        do {
            let realm = try! Realm()
            try realm.write{
                realm.add(city)
            }
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let destination = sb.instantiateViewController(withIdentifier: "Navigation")
            self.navigationController?.pushViewController(destination, animated: true)
        } catch {
            print("Error in initializing realm")
        }
    }

}
