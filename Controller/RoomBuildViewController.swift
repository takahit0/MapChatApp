//
//  RoomBuildViewController.swift
//  MapChatApp
//
//

import UIKit
import MapKit
import CoreLocation

@available(iOS 15.0, *)
@available(iOS 15.0, *)
class RoomBuildViewController: UIViewController {

    @IBOutlet weak var roomName: UITextView!
    @IBOutlet weak var roomContents: UITextView!
    
    var latitude = String()
    var longitude = String()
    var region = MKCoordinateRegion()
    var mapViewLoc = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func build(_ sender: Any) {
        let mapVC = self.storyboard?.instantiateViewController(identifier: "mapVC") as! MapViewController
        mapVC.lat = latitude
        mapVC.lon = longitude
        mapVC.theRegion = region
        mapVC.mapView = mapViewLoc
        mapVC.buildPin(name: roomName.text, contents: roomContents.text)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func stopBuild(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
