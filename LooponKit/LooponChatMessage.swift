//
//  LooponChatMessage.swift
//  LooponKit
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation

public class LooponChatMessage: LooponEvent
{
	public var sessionId: String
	public let created: Date
	public let type: LooponEventType

	/// Unique identifier of this message. A message with the same `id` might be deliveredmore than once,
	/// often because one/some of its details have been updated, such as the `updated` timestamp.
	public let id: Int

	/// Date when the chat message was updated. If the message was never updated, will be `nil`.
	///
	/// Includes milliseconds and original timezone.
	public let updated: Date?

	/// Date when the chat message was read by the counterpart agent. If the message was never read, will be `nil`.
	///
	/// Includes milliseconds and original timezone.
	public let read: Date?

	/// Id provided the the client that generated this message. Can be used to keep track of correct delivery without
	/// relying on guesswork.
	public let localId: String

	/// Content of message (valid for `text/plain` and `text/html`).
	public let url: URL?

	/// Fully qualified URL to content data (valid for `image/png`, `image/gif` and `image/jpeg`) content types.
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
		updated = try chatEventContainer.decode(Swift.type(of: updated), forKey: .updated)
		read = try chatEventContainer.decode(Swift.type(of: read), forKey: .read)
		localId = try chatEventContainer.decode(Swift.type(of: localId), forKey: .localId)
		url = try chatEventContainer.decode(Swift.type(of: url), forKey: .url)
		content = try chatEventContainer.decode(Swift.type(of: content), forKey: .content)
		contentType = try chatEventContainer.decode(Swift.type(of: contentType), forKey: .contentType)
	}

	/// Creates a message event with a string.
	public init(content: String, type: ContentType, localId: String? = nil)
	{
		let created = Date()

		self.sessionId = ""
		self.created = created
		self.type = .chatMessage
		self.id = 0
		self.updated = nil
		self.read = nil
		self.url = nil
		self.content = content
		self.contentType = type
		self.localId = localId ?? "\(content)\(created.timeIntervalSince1970)\(arc4random())".sha256Hash.base64Encoded
	}

	/// Creates a message event with an attributed string.
//	public init(content: NSAttributedString, type: ContentType, localId: String? = nil)
//	{
//		let created = Date()
//
//		//		self.sessionId = ""
//		self.created = created
//		self.type = .chatMessage
//		self.id = 0
//		self.updated = nil
//		self.read = nil
//		self.url = nil
//		self.content = content
//		self.contentType = type
//		self.localId = localId ?? "\(content)\(created.timeIntervalSince1970)\(arc4random())".sha256Hash.base64Encoded
//	}

	/// Creates a message event with a URL.
	public init(url: URL, type: ContentType, localId: String? = nil)
	{
		let created = Date()

		self.sessionId = ""
		self.created = created
		self.type = .chatMessage
		self.id = 0
		self.updated = nil
		self.read = nil
		self.url = url
		self.content = nil
		self.contentType = type
		self.localId = localId ?? "\(url.absoluteString)\(created.timeIntervalSince1970)\(arc4random())".sha256Hash.base64Encoded
	}

	public func encode(to encoder: Encoder) throws
	{
		var looponEventContainer = encoder.container(keyedBy: CodingKeys.self)
		try looponEventContainer.encode(sessionId, forKey: .sessionId)
		try looponEventContainer.encode(created, forKey: .created)
		try looponEventContainer.encode(type, forKey: .type)

		var chatEventContainer = looponEventContainer.nestedContainer(keyedBy: ChatMessageKeys.self,
																	  forKey: .chatMessage)

		try chatEventContainer.encode(id, forKey: .id)
		try chatEventContainer.encode(updated, forKey: .updated)
		try chatEventContainer.encode(read, forKey: .read)
		try chatEventContainer.encode(localId, forKey: .localId)
		try chatEventContainer.encode(url, forKey: .url)
		try chatEventContainer.encode(content, forKey: .content)
		try chatEventContainer.encode(contentType, forKey: .contentType)
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
		case updated
		case read
		case localId
		case url
		case content
		case contentType
	}
}
