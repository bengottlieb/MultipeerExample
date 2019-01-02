//
//  Scanner.swift
//  MultipeerExample
//
//  Created by Ben Gottlieb on 8/18/18.
//  Copyright © 2018 Stand Alone, Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MPCManager: NSObject {
	var advertiser: MCNearbyServiceAdvertiser!
	var browser: MCNearbyServiceBrowser!

	struct Notifications {
		static let deviceDidChangeState = Notification.Name("deviceDidChangeState")
	}
	
	static let instance = MPCManager()
	
	let localPeerID: MCPeerID
	let serviceType = "MPC-Testing"
	
	var devices: [Device] = []
	
	
	override init() {
		if let data = UserDefaults.standard.data(forKey: "peerID"), let id = NSKeyedUnarchiver.unarchiveObject(with: data) as? MCPeerID {
			self.localPeerID = id
		} else {
			let peerID = MCPeerID(displayName: UIDevice.current.name)
			let data = NSKeyedArchiver.archivedData(withRootObject: peerID)
			UserDefaults.standard.set(data, forKey: "peerID")
			self.localPeerID = peerID
		}
		
		super.init()
		
		self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: self.serviceType)
		self.advertiser.delegate = self
		
		self.browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: self.serviceType)
		self.browser.delegate = self
	}
	
	func device(for id: MCPeerID) -> Device {
		for device in self.devices {
			if device.peerID == id { return device }
		}
		
		let device = Device(peerID: id)
		
		self.devices.append(device)
		return device
	}

	func start() {
		self.advertiser.startAdvertisingPeer()
		self.browser.startBrowsingForPeers()
		
		NotificationCenter.default.addObserver(self, selector: #selector(enteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
	}
	
	@objc func enteredBackground() {
		for device in self.devices {
			device.disconnect()
		}
	}
}

extension MPCManager {
	var connectedDevices: [Device] {
		return self.devices.filter { $0.state == .connected }
	}
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		let device = MPCManager.instance.device(for: peerID)
		device.connect()
		invitationHandler(true, device.session)
		//  Handle our incoming peer
	}
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		let device = MPCManager.instance.device(for: peerID)
		device.invite(with: self.browser)
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		let device = MPCManager.instance.device(for: peerID)
		device.disconnect()
	}
}


