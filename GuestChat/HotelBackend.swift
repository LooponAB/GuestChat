//
//  HotelBackend.swift
//  GuestChat
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

class HotelBackend
{
	private let clientId: String
	private let clientSecret: String

	init(clientId: String, secret: String)
	{
		self.clientId = clientId
		self.clientSecret = secret
	}
}
