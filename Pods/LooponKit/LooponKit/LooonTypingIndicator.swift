//
//  LooonTypingIndicator.swift
//  LooponKit
//
//  Created by Bruno Resende on 22/11/2017.
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

/// The TypingIndicator message acts as a notification that someone is currently typing a message. When your guest app
/// is sending a TypingIndicator, you don’t even need to include the typingIndicator field in the LooponEvent message.
///
/// Just keep sending a LooponEvent of type typingIndicator at around 5 second intervals, as long as the guest is still
/// typing a message.
///
/// When you receive a LooponEvent of type typingIndicator you should show a typing indicator, optionally together with
/// the authorName field to signal who at the hotel is typing a message. You should make the indicator automatically
/// disappear after timeout seconds, unless you receive a new typingIndicator LooponEvent before that in which case you
/// should reset the timeout to the new value - don’t add it!
public class LooponTypingIndicator: LooponEvent
{
	public var sessionId: String
	public let created: LooponDate
	public let type: LooponEventType

	/// Number of seconds this typing indicator should max be visible.
	public let timeout: Int

	/// Identifier of who is currently typing a message.
	public let author: LooponComposer

	/// Name of the author currently writing a message.
	public let authorName: String

	/// URL to an avatar of the author currently writing a message.
	public let authorAvatarUrl: URL?
}
