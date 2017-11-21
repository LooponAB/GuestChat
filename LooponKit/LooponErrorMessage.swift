//
//  LooponErrorMessage.swift
//  LooponKit
//
//  Created by Bruno Resende on 20/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

public class LooponErrorMessage: LooponEvent
{
	public var sessionId: String
	public let created: LooponDate
	public let type: LooponEventType

	/// The error message as provided by the server.
	public let errorMessage: String
}
