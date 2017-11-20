//
//  LooponSocket.swift
//  LooponKit
//
//  Created by Bruno Resende on 17/11/2017.
//  Copyright © 2017 Loopon AB. All rights reserved.
//

import Foundation
import SocketRocket

public protocol LooponSocketDelegate
{
	func looponSocket(_ socket: LooponSocket, received chatMessage: LooponChatMessage)
}

/// Class used to manage a socket connection to Loopon's chat servers.
public class LooponSocket: NSObject
{
	/// The appropriate delegate method is called every time the socket receives a message. `LooponSocket` takes care
	/// of parsing the socket data into objects.
	public var delegate: LooponSocketDelegate? = nil

	public var url: URL? = nil
	{
		didSet
		{
			// We only attempt to connect if we have a URL to use.
			reconnectSocket()
		}
	}

	public func send(chatMessage: LooponChatMessage) -> Error?
	{
		do
		{
			let data = try JSONEncoder().encode(chatMessage)
			socket?.send(data)

			return nil
		}
		catch
		{
			return error
		}
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

		// Gracefully close old timer
		if let existingSocket = socket
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
		}
	}

	@objc private func watchdogTimerDidFire(_ timer: Timer)
	{
		if socket?.readyState == .CLOSED
		{
			reconnectSocket()
		}
	}
}

extension LooponSocket: SRWebSocketDelegate
{
	public func webSocketDidOpen(_ webSocket: SRWebSocket!)
	{

	}

	public func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool)
	{
		if !wasClean
		{
			reconnectSocket()
		}
	}

	public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!)
	{

	}
}
