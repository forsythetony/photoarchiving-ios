//
//  File.swift
//  PAPhotoArchivingTimelineView
//
//  Created by Tony Forsythe on 11/26/16.
//  Copyright © 2016 Tony Forsythe. All rights reserved.
//

import Foundation
import GoogleCast

protocol PAChromeCasterDelegate {
    func didFindNewDevice( device : GCKDevice)
    func didConnectToDevice( device : GCKDevice )
    
    
}
class PAChromecaster: NSObject, GCKDeviceScannerListener,GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate {
    
    //  MARK: Object Properties
    static let sharedInstance = PAChromecaster()
    
    let receiverAppID = "94B7DFA1"
    var deviceScanner : GCKDeviceScanner?
    var connectedDevice : GCKDevice?
    var deviceMan : GCKDeviceManager?
    var mediaChannel : GCKMediaControlChannel?
    
    var delegate : PAChromeCasterDelegate?
    
    var isOnline : Bool {
        get {
            if let con_dev = self.deviceMan {
                return con_dev.isConnected
            }
            
            return false
        }
    }
    
    
    override init() {
        super.init()
        setupChromecast()
    }
    
    func setupChromecast() {
        /*
        deviceScanner = GCKDeviceScanner()
        deviceScanner?.add(self)
        */
        
    }
    
    //  MARK: Device Scanner Delegate Functions
    func beginSearching() {
        deviceScanner?.startScan()
    }
    func deviceDidGoOffline(_ device: GCKDevice!) {
        
    }
    func deviceDidComeOnline(_ device: GCKDevice!) {
        self.delegate?.didFindNewDevice(device: device)
    }
    
    //  MARK: Device Manager Delegate Functions
    func deviceManagerDidConnect(_ deviceManager: GCKDeviceManager!) {
        TFLogger.log(logString: "Manager did connect!")
        deviceManager.launchApplication(receiverAppID)
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, didDisconnectWithError error: Error!) {
        
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, didFailToConnectWithError error: Error!) {
        
        TFLogger.log(logString: "Failed to connect 1 with error %@", arguments: error.localizedDescription)
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, didFailToStopApplicationWithError error: Error!) {
        
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, didReceive activeInputStatus: GCKActiveInputStatus) {
        
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, didDisconnectFromApplicationWithError error: Error!) {
        TFLogger.log(logString: "Disconnected from application with error %@", arguments: error.localizedDescription)
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, didFailToConnectToApplicationWithError error: Error!) {
        TFLogger.log(str: "Failed to connect", err: error)
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, volumeDidChangeToLevel volumeLevel: Float, isMuted: Bool) {
        
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, didReceiveStatusForApplication applicationMetadata: GCKApplicationMetadata!) {
        
    }
    func deviceManager(_ deviceManager: GCKDeviceManager!, didConnectToCastApplication applicationMetadata: GCKApplicationMetadata!, sessionID: String!, launchedApplication: Bool) {
        
        mediaChannel = GCKMediaControlChannel()
        mediaChannel?.delegate = self
        self.deviceMan?.add(mediaChannel!)
        self.mediaChannel?.requestStatus()
    }
    func mediaControlChannelDidUpdateStatus(_ mediaControlChannel: GCKMediaControlChannel!) {
        
    }
    
    func mediaControlChannelDidUpdateMetadata(_ mediaControlChannel: GCKMediaControlChannel!) {
        
        
    }
    
    func mediaControlChannel(_ mediaControlChannel: GCKMediaControlChannel!, requestDidCompleteWithID requestID: Int) {
        
    }
    func mediaControlChannel(_ mediaControlChannel: GCKMediaControlChannel!, didFailToLoadMediaWithError error: Error!) {
        
    }
    func mediaControlChannel(_ mediaControlChannel: GCKMediaControlChannel!, didCompleteLoadWithSessionID sessionID: Int) {
        
    }
    func mediaControlChannel(_ mediaControlChannel: GCKMediaControlChannel!, requestDidFailWithID requestID: Int, error: Error!) {
        
    }
    func sendStory( story : PAStory, photo : PAPhotograph?) {
        /*
        guard let device_man = self.deviceMan else { return }
        
        guard isOnline else { return }
        
        let metadata = GCKMediaMetadata()
        
        metadata?.setString(story.title, forKey: kGCKMetadataKeyTitle)
        
        if let photo_info = photo {
            let size = CGSize(width: 200.0, height: 200.0)
            
            let photo_url = URL(string: photo_info.thumbnailURL)
            
            let image_to_send = GCKImage(url: photo_url, width: Int(size.width), height: Int(size.height))
            
            metadata?.addImage(image_to_send)
            
            if let date_taken = photo_info.dateTaken {
                let date_str = PADateManager.sharedInstance.getDateString(date: date_taken, formatType: .Pretty)
                
                metadata?.setString(date_str, forKey: kGCKMetadataKeySubtitle)
            }
        }
        
        let media_info = GCKMediaInformation(contentID: story.recordingURL, streamType: .unknown , contentType: "audio/mp4", metadata: metadata, streamDuration: 0, customData: nil)
        
        self.mediaChannel?.loadMedia(media_info)
    */
    }
    
    func sendPhoto( photo : PAPhotograph ) {
        
        guard let device_man = self.deviceMan else {
            TFLogger.log(logString: "I'm not connected")
            return
        }
        
        guard device_man.isConnected else {
            TFLogger.log(logString: "I'm still not connected")
            return
        }
        
        let metadata = GCKMediaMetadata()
        
        metadata.setString(photo.title, forKey: kGCKMetadataKeyTitle)
        
        let mediaInfo = GCKMediaInformation(contentID: photo.mainImageURL, streamType: GCKMediaStreamType.unknown, contentType: "image/jpg", metadata: metadata, streamDuration: 0, customData: nil)
        
        mediaChannel?.loadMedia(mediaInfo)
        
    }

    
    func connectToDevice( dev : GCKDevice ) {
        
        self.connectedDevice = dev
        
        self.deviceMan = GCKDeviceManager(device: self.connectedDevice!, clientPackageName: Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String!)
        self.deviceMan?.delegate = self
        self.deviceMan?.connect()
    }
    
    
    
}
