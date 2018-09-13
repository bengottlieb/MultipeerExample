//
//  Message.swift
//  MultipeerExample
//
//  Created by Ben Gottlieb on 9/12/18.
//  Copyright © 2018 Stand Alone, Inc. All rights reserved.
//

import Foundation

struct Message: Codable {
	let body: String
}

extension Device {
	func send(text: String) throws {
		let message = Message(body: text)
		let payload = try JSONEncoder().encode(message)
		try self.session?.send(payload, toPeers: [self.peerID], with: .reliable)
	}
}
