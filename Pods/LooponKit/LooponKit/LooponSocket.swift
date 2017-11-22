//
//  LooponSocket.swift
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
import SocketRocket

/// LooponSocket delegate calls are alwas sent   the main queue.
public protocol LooponSocketDelegate
{
	/// Sent when the socket connects successfully.
	func looponSocketDidOpen(_ looponSocket: LooponSocket)

	/// Sent when the socket closes. If this was caused by an error or timeout, `didCloseCleanly` will be `false`, and
	/// LooponSocket will automatically attempt to reopen the connection.
	/// If this succeeds, another call to `looponSocketDidOpen:` will be made.
	func looponSocket(_ looponSocket: LooponSocket, didCloseCleanly: Bool)

	/// Sent when a message is received through the socket.
	func looponSocket(_ socket: LooponSocket, received chatMessage: LooponChatMessage)

	/// Sent when an error message is received through the socket.
	func looponSocket(_ socket: LooponSocket, received errorMessage: LooponErrorMessage)

	/// Sent when a typing indicator is received through the socket.
	func looponSocket(_ socket: LooponSocket, received typingIndicator: LooponTypingIndicator)

	/// Sent when a runtime error happens.
	func looponSocket(_ socket: LooponSocket, producedError error: Error)
}

/// Class used to manage a socket connection to Loopon's chat servers.
public class LooponSocket: NSObject
{
	/// The appropriate delegate method is called every time the socket receives a message. `LooponSocket` takes care
	/// of parsing the socket data into objects.
	public var delegate: LooponSocketDelegate? = nil

	private let jsonDecoder = JSONDecoder()

	public var url: URL? = nil
	{
		didSet
		{
			// We only attempt to connect if we have a URL to use.
			reconnectSocket()
		}
	}

	public func send(chatMessage: LooponChatMessage) throws
	{
		socket?.send(try JSONEncoder().encode(chatMessage))
	}

	/// Closes the socket cleanly.
	public func close()
	{
		socket?.close()
	}

	// MARK: Private Memebers

	private var socket: SRWebSocket? = nil
	private var socketWatchdogTimer: Timer? = nil

	private func reconnectSocket()
	{
		// Stop the old watchdog timer
		if let existingTimer = socketWatchdogTimer
		{
			existingTimer.invalidate()
		}

		// Gracefully close old socket
		if let existingSocket = socket, existingSocket.readyState != .CLOSED
		{
			existingSocket.close()
		}

		// If we have a URL, try to open a socket with it
		if let url = self.url, let newSocket = SRWebSocket(url: url)
		{
			newSocket.delegate = self

			// Setup a new watchdog timer
			let newTimer = Timer.scheduledTimer(timeInterval: 6.0, target: self,
												selector: #selector(LooponSocket.watchdogTimerDidFire(_:)),
												userInfo: nil, repeats: true)

			// Store the new objects
			self.socket = newSocket
			self.socketWatchdogTimer = newTimer

			// Open the socket
			newSocket.open()
		}
	}

	@objc private func watchdogTimerDidFire(_ timer: Timer)
	{
		if socket?.readyState == .CLOSED
		{
			reconnectSocket()
		}
	}

	enum SocketError: Error
	{
		case badSocketMessage(Any)
	}

	private func parseSocketMessage(_ socketMessage: String)
	{
		guard let delegate = self.delegate else
		{
			print("Got chat socket message, but delegate is not set!!")
			return
		}

		let messages = socketMessage.split(separator: Character("\n"))

		for message in messages
		{
			if let messageData = message.data(using: .utf8)
			{
				do
				{
					let event = try jsonDecoder.decode(LooponConcreteEvent.self, from: messageData)

					switch event.type
					{
					case .chatMessage:
						let message = try jsonDecoder.decode(LooponChatMessage.self, from: messageData)
						DispatchQueue.main.async { delegate.looponSocket(self, received: message) }

					case .typingIndicator:
						let typingIndicator = try jsonDecoder.decode(LooponTypingIndicator.self, from: messageData)
						DispatchQueue.main.async { delegate.looponSocket(self, received: typingIndicator) }

					case .errorMessage:
						let error = try jsonDecoder.decode(LooponErrorMessage.self, from: messageData)
						DispatchQueue.main.async { delegate.looponSocket(self, received: error) }
					}
				}
				catch
				{
					print("Failed parsing socket message! \(error)")
					DispatchQueue.main.async { delegate.looponSocket(self, producedError: error) }
				}
			}
		}
	}
}

extension LooponSocket: SRWebSocketDelegate
{
	public func webSocketDidOpen(_ webSocket: SRWebSocket!)
	{
		if let delegate = self.delegate
		{
			DispatchQueue.main.async { delegate.looponSocketDidOpen(self) }
		}
	}

	public func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool)
	{
		if !wasClean
		{
			reconnectSocket()
		}

		if let delegate = self.delegate
		{
			DispatchQueue.main.async { delegate.looponSocket(self, didCloseCleanly: wasClean) }
		}
	}

	public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!)
	{
		if let messageString = message as? String
		{
			parseSocketMessage(messageString)
		}
		else if let messageData = message as? Data, let messageString = String(data: messageData, encoding: .utf8)
		{
			parseSocketMessage(messageString)
		}
		else
		{
			print("Could not parse socket message! \(message)")

			if let delegate = self.delegate
			{
				let error = SocketError.badSocketMessage(message)
				DispatchQueue.main.async { delegate.looponSocket(self, producedError: error) }
			}
		}
	}
}
