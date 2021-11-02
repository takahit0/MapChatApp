//
//  ViewController.swift
//  MapChatApp
//
//

import UIKit
import MapKit
import CoreLocation
import Firebase

@available(iOS 15.0, *)
class MapViewController: UIViewController,CLLocationManagerDelegate,UITextFieldDelegate,MKMapViewDelegate,LoadOKDelegate,UIPickerViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var search: UIButton!
    
    var locManager:CLLocationManager!
    var pin:MKPointAnnotation!
    var loadLocationModel = LoadLocationModel()
    let db = Firestore.firestore()
    var location = CGPoint()
    var name = String()
    var contents = String()
    var lat = String()
    var lon = String()
    var theRegion = MKCoordinateRegion()
    var userName = String()
    var imageString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputText.delegate = self
        mapView.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.startUpdatingLocation()
        locManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        search.layer.cornerRadius = 20.0
        loadLocationModel.loadOKDelegate = self
    }
    
    func loadOK(check: Int) {
        //ピンをマップに表示させたい
        let idoValue = loadLocationModel.pinData[check].latitude
        let keidoValue = loadLocationModel.pinData[check].longitude
        let coordinate = CLLocationCoordinate2DMake(idoValue, keidoValue)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLocationModel.getPins()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let searchKeyword = textField.text {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchKeyword) { placemarks, error in
                if let placemark = placemarks?[0]{
                    if let targetCoordinate = placemark.location?.coordinate{
                        let pin = MKPointAnnotation()
                        pin.coordinate = targetCoordinate
                        self.mapView.addAnnotation(pin)
                        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        let theRegion = MKCoordinateRegion(center: targetCoordinate, span: span)
                        self.mapView.setRegion(theRegion, animated: true)
                    }
                }
            }
        }
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let longitude = (locations.last?.coordinate.longitude.description)!
        let latitude = (locations.last?.coordinate.latitude.description)!
        print("longitude : " + longitude)
        print("latitude : " + latitude)
        //現在地の更新
        mapView.setCenter((locations.last?.coordinate)!, animated: true)
    }
    
    @IBAction func longPressMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began{
            return
        }
        //ロングタップした時の位置情報を取得してlocationに代入
        location = sender.location(in: mapView)
        let center = mapView.convert(location, toCoordinateFrom: mapView)
        lat = center.latitude.description
        lon = center.longitude.description
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        theRegion = MKCoordinateRegion(center: center, span: span)
        //掲示板作成画面に遷移する
        let roomBuildVC = self.storyboard?.instantiateViewController(identifier: "roomBuildVC") as! RoomBuildViewController
        roomBuildVC.latitude = lat
        roomBuildVC.longitude = lon
        roomBuildVC.region = theRegion
        roomBuildVC.mapViewLoc = mapView
        self.navigationController?.pushViewController(roomBuildVC, animated: true)
    }
    
    func buildPin(name: String,contents: String){
        pin = MKPointAnnotation()
        //取得した位置情報を座標に変換
        let coordinate = CLLocationCoordinate2DMake(Double(lat)!, Double(lon)!)
        //座標をピンに設定
        pin.coordinate = coordinate
        //ピンを追加する
        mapView.addAnnotation(pin)
        savePin(latitude: lat, longitude: lon, roomName: name, roomContents: contents)
    }
    
    func savePin(latitude: String,longitude: String,roomName: String,roomContents: String) {
        db.collection("location").document(roomName).setData(["latitude": latitude,"longitude": longitude,"roomName": roomName,"roomContents": roomContents])
    }
    
    @IBAction func searchLocation(_ sender: Any) {
        //検索した地名の付近を画面に表示する
        inputText.resignFirstResponder()
        if let searchKeyword = inputText.text {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(searchKeyword) { placemarks, error in
                if let placemark = placemarks?[0]{
                    if let targetCoordinate = placemark.location?.coordinate{
                        print(targetCoordinate)
                        let pin = MKPointAnnotation()
                        pin.coordinate = targetCoordinate
                        self.mapView.addAnnotation(pin)
                        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        let theRegion = MKCoordinateRegion(center: targetCoordinate, span: span)
                        self.mapView.setRegion(theRegion, animated: true)
                    }
                }
            }
        }
    }
    
    @available(iOS 15.0, *)
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation{
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            let lat = annotation.coordinate.latitude
            let lon = annotation.coordinate.longitude
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "modalVC") as! ModalViewController
            vc.userName = userName
            vc.imageString = imageString
            for i in loadLocationModel.pinData{
                if i.latitude == lat, i.longitude == lon{
                    name = i.roomName
                    vc.name = i.roomName
                    vc.contents = i.roomContents
                }
            }
            //ハーフモーダルでmodalVCを表示させる
            if #available(iOS 15.0, *) {
                if let sheet = vc.sheetPresentationController {
                    sheet.detents = [.medium()]
                }
                self.navigationController?.present(vc, animated: true, completion: nil)
            } else {
                print("エラー")
            }
        }
    }
}

