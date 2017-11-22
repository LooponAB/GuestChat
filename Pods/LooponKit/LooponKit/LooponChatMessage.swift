//
//  LooponChatMessage.swift
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

/// Describes a chat message written either by the guest or the hotel.
open class LooponChatMessage: LooponEvent
{
	public var sessionId: String
	public let created: LooponDate
	public let type: LooponEventType

	/// Unique identifier of this message. A message with the same `id` might be deliveredmore than once,
	/// often because one/some of its details have been updated, such as the `updated` timestamp.
	public let id: Int

	/// Date when the chat message was read by the counterpart agent. If the message was never read, will be `nil`.
	///
	/// Includes milliseconds and original timezone.
	public let read: LooponDate?

	/// Id provided the the client that generated this message. Can be used to keep track of correct delivery without
	/// relying on guesswork.
	public let localId: String?

	/// Which interlocutor composed this message.
	public let author: LooponComposer

	/// User-displayable name of the author of this message.
	public let authorName: String

	/// If available, a URL for an avatar for the user.
	public let authorAvatarUrl: URL?

	/// Which media was used to send/receive this message.
	public let media: Media

	/// Fully qualified URL to content data (valid for `image/png`, `image/gif` and `image/jpeg`) content types.
	public let url: URL?

	/// Content of message (valid for `text/plain` and `text/html`).
	public let content: String?

	/// Describes the type of content included in this chat message.
	public let contentType: ContentType

	public required init(from decoder: Decoder) throws
	{
		let looponEventContainer = try decoder.container(keyedBy: CodingKeys.self)
		sessionId = try looponEventContainer.decode(Swift.type(of: sessionId), forKey: .sessionId)
		created = try looponEventContainer.decode(Swift.type(of: created), forKey: .created)
		type = try looponEventContainer.decode(Swift.type(of: type), forKey: .type)

		let chatEventContainer = try looponEventContainer.nestedContainer(keyedBy: ChatMessageKeys.self,
																		  forKey: .chatMessage)

		id = try chatEventContainer.decode(Swift.type(of: id), forKey: .id)
		read = try chatEventContainer.decode(Swift.type(of: read), forKey: .read)
		localId = try chatEventContainer.decode(Swift.type(of: localId), forKey: .localId)
		author = try chatEventContainer.decode(Swift.type(of: author), forKey: .author)
		authorName = try chatEventContainer.decode(Swift.type(of: authorName), forKey: .authorName)
		authorAvatarUrl = try chatEventContainer.decode(Swift.type(of: authorAvatarUrl), forKey: .authorAvatarUrl)
		media = try chatEventContainer.decode(Swift.type(of: media), forKey: .media)
		url = try chatEventContainer.decode(Swift.type(of: url), forKey: .url)
		content = try chatEventContainer.decode(Swift.type(of: content), forKey: .content)
		contentType = try chatEventContainer.decode(Swift.type(of: contentType), forKey: .contentType)
	}

	/// Creates a message event with a string.
	public init(content: String, type: ContentType, localId: String? = nil)
	{
		let created = LooponDate()

		self.sessionId = ""
		self.created = created
		self.type = .chatMessage
		self.id = 0
		self.read = nil
		self.url = nil
		self.content = content
		self.contentType = type
		self.author = .guest
		self.authorName = ""
		self.authorAvatarUrl = nil
		self.media = .webchat

		self.localId = localId ?? "\(content)\(created.date.timeIntervalSince1970)\(arc4random())".sha256Hash.base64Encoded
	}

	/// Creates a message event with a URL.
	public init(url: URL, type: ContentType, localId: String? = nil)
	{
		let created = LooponDate()

		self.sessionId = ""
		self.created = created
		self.type = .chatMessage
		self.id = 0
		self.read = nil
		self.url = url
		self.content = nil
		self.contentType = type
		self.author = .guest
		self.authorName = ""
		self.authorAvatarUrl = nil
		self.media = .webchat

		self.localId = localId ?? "\(url.absoluteString)\(created.date.timeIntervalSince1970)\(arc4random())".sha256Hash.base64Encoded
	}

	public func encode(to encoder: Encoder) throws
	{
		var looponEventContainer = encoder.container(keyedBy: CodingKeys.self)
		try looponEventContainer.encode(type, forKey: .type)

		var chatEventContainer = looponEventContainer.nestedContainer(keyedBy: ChatMessageKeys.self,
																	  forKey: .chatMessage)

		try chatEventContainer.encode(localId, forKey: .localId)
		try chatEventContainer.encode(contentType, forKey: .contentType)
		try chatEventContainer.encode(url, forKey: .url)
		try chatEventContainer.encode(content, forKey: .content)
	}

	public enum Media: String, Codable
	{
		/// Message sent using SMS subsystem.
		case sms

		/// Message sent using facebook messenger subsystem.
		case facebook

		/// Message sent using Loopon chat.
		case webchat

		/// Message sent though the public API.
		case appchat

		/// Message sent through email.
		case email
	}

	/// The mime type of the chat message contents.
	public enum ContentType: String, Codable
	{
		/// Plain text message with no styling.
		///
		/// `content` will contain the plain string.
		case plainText	= "text/plain"

		/// Rich text formatted with very limited subset of HTML. Loopon ensures whitelist of allowed tags in backend,
		/// so this is safe to display as-is.
		///
		/// `content` will contain the HTML string.
		case richText	= "text/html"

		/// Image in PNG format.
		///
		/// `url` will contain the url for this message.
		case pngImage	= "image/png"

		/// Image in PNG format.
		///
		/// `url` will contain the url for this message.
		case gifImage	= "image/gif"

		/// Image in PNG format.
		///
		/// `url` will contain the url for this message.
		case jpgImage	= "image/jpeg"
	}

	/// Keys used to decode the loopon event object.
	enum CodingKeys: String, CodingKey
	{
		case sessionId
		case created
		case type
		case chatMessage
	}

	/// Keys used to decode the nested chat message object.
	enum ChatMessageKeys: String, CodingKey
	{
		case id
		case read
		case localId
		case author
		case authorName
		case authorAvatarUrl
		case url
		case content
		case contentType
		case media
	}
}

extension LooponChatMessage: Equatable
{
	public static func ==(lhs: LooponChatMessage, rhs: LooponChatMessage) -> Bool
	{
		return lhs.localId == rhs.localId
	}
}

extension LooponChatMessage: Comparable
{
	public static func <(lhs: LooponChatMessage, rhs: LooponChatMessage) -> Bool
	{
		return lhs.created.date > rhs.created.date
	}
}
