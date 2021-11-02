//
//  CheckModel.swift
//  MapChatApp
//
//

import Foundation
import Photos

class CheckModel {
    func checkPermissions() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .notDetermined:
                print("未決定")
            case .restricted:
                print("制限されています")
            case .denied:
                print("拒否されています")
            case .authorized:
                print("許可されています")
            case .limited:
                print("限定されています")
            @unknown default:
                break
            }
        }
    }
}
