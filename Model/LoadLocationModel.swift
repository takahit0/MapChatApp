//
//  LoadLocationModel.swift
//  MapChatApp
//
//

import Foundation
import Firebase

protocol LoadOKDelegate {
    
    func loadOK(check:Int)
}

class LoadLocationModel {
    
    var pinData = [PinModel]()
    let db = Firestore.firestore()
    
    var loadOKDelegate:LoadOKDelegate?
    
    func getPins() {
        var number = 0
        db.collection("location").getDocuments { (snaps, error) in
            
            self.pinData = []
            
            
            if error != nil {
                print(error.debugDescription)
            }else{
                if let snapDoc = snaps?.documents{
                    for doc in snapDoc {
                        let data = doc.data()
                        
                        let lat = data["latitude"]! as? NSString
                        let lon = data["longitude"]! as? NSString
                        let roomName = data["roomName"]! as? String
                        let roomContents = data["roomContents"]! as? String
                        
                        let newData = PinModel(latitude: lat!.doubleValue, longitude: lon!.doubleValue, roomName: roomName!, roomContents: roomContents!)
                        self.pinData.append(newData)
                        self.loadOKDelegate?.loadOK(check: number)
                        number += 1
                        
                    
                    }
                }
            }
        }
    }
}
