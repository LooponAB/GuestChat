//
//  LooponEvent.swift
//  LooponKit
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB
//  API Documentation: https://api.loopon.com/public
//  Contact us at support@loopon.com
//  
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
//  following conditions are met:
//  
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
//  disclaimer.
//  
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
//  following disclaimer in the documentation and/or other materials provided with the distribution.
//  
//  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
//  products derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
//  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

/// All messages passed by Loopon on both the WebSocket connection as well as to the registered callback URL for the
/// guest application backend will be of type LooponEvent.
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

/// Class used by LooponSocket as a helper to decide which kind of message to try decoding.
internal class LooponConcreteEvent: LooponEvent
{
	var sessionId: String
	var created: LooponDate
	var type: LooponEventType
}

public enum LooponEventType: String, Codable
{
	/// Either guest or hotel has written a message.
	case chatMessage

	/// Either guest or hotel is currently composing a message.
	case typingIndicator

	/// Error report for event previously sent by client; mostly for debugging purposes.
	case errorMessage
}
