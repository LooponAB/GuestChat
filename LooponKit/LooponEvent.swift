//
//  LooponEvent.swift
//  LooponKit
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

public protocol LooponEvent: Codable
{
	/// Unique identifier of the chat session this event is associated with. Note that this session id is used for
	/// authenticating the client, so it should be considered a secret.
	var sessionId: String { get }

	/// Date and time when the event was initially created.
	///
	/// Includes milliseconds and original timezone.
	var created: LooponDate { get }

	/// Identifier of the type of event, which defines the rest of the content of the LooponEvent.
	var type: LooponEventType { get }
}

public enum LooponEventType: String, Codable
{
	/// Either guest or hotel has written a message.
	case chatMessage

	/// Either guest or hotel is currently composing a message.
	case typingIndicator

	/// Error report for event previously sent by client; mostly for debugging purposes.
	case error
}
