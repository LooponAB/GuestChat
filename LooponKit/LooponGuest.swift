//
//  LooponGuest.swift
//  LooponKit
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

/// Representation of a single guest (person + unit). All contact details are nullable and will be null in the case of
/// an anonymous guest. For anonymous guests a new guestId will always be generated, so you cannot use a non-anonymous
/// guest’s guestId from a chat to identify answers to the post-stay survey.
public class LooponGuest: Codable
{
	/// Unique identifier of a specific guest.
	public let guestId: Int

	/// Full name of guest.
	public let name: String?

	/// E-mail address of guest.
	public let email: String?

	/// Mobile phone number of guest in full international format
	public let mobile: String?

	public init(name: String?, email: String?, mobile: String?)
	{
		self.guestId = 0
		self.name = name
		self.email = email
		self.mobile = mobile
	}
}
