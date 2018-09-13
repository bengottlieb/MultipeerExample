//
//  ViewController.swift
//  MultipeerExample
//
//  Created by Ben Gottlieb on 8/18/18.
//  Copyright © 2018 Stand Alone, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	
	var devices: [Device] = []
	
	@objc func reload( ){
		self.devices = Array(MPCManager.instance.devices).sorted(by: { $0.name < $1.name })
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(reload), name: MPCManager.Notifications.deviceDidChangeState, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reload), name: MPCManager.Notifications.deviceDidChangeState, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Device.messageReceivedNotification, object: nil)
		
		self.reload()
	}


}

extension ViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.devices.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
		let device = self.devices[indexPath.row]
		cell.textLabel?.text = "\(device.name) - \(device.state.rawValue)"
		cell.detailTextLabel?.text = device.lastMessageReceived?.body
		return cell
	}
}

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let device = self.devices[indexPath.row]
		let alert = UIAlertController(title: "Send To \(device.name)", message: "Enter your message:", preferredStyle: .alert)
		alert.addTextField { field in }
		
		alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
			if let text = alert.textFields?.first?.text {
				try? device.send(text: text)
			}
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}
