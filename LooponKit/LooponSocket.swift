//
//  LooponSocket.swift
//  LooponKit
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
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
		let data = try JSONEncoder().encode(chatMessage)

		print("Sending JSON: \(String(data: data, encoding: .utf8) ?? "null data")")

		socket?.send(data)
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
					let message = try jsonDecoder.decode(LooponChatMessage.self, from: messageData)
					DispatchQueue.main.async { delegate.looponSocket(self, received: message) }
				}
				catch
				{
					print("Failed parsing socket message! \(error)")
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
			DispatchQueue.main.async
				{
					delegate.looponSocketDidOpen(self)
				}
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
			DispatchQueue.main.async
				{
					delegate.looponSocket(self, didCloseCleanly: wasClean)
				}
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
		}
	}
}
