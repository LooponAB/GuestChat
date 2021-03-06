//
//  ChatViewController.swift
//  GuestChat
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

import UIKit
import ChatWow
import LooponKit

class ChatViewController: ChatWowViewController
{
	private var chatSocket = LooponSocket()

	private var chatMessages = [LooponChatMessage]()
	private var pendingChatMessages = [PendingChatMessage]()

	private var guestStay: LooponGuestStay? = nil
	{
		didSet
		{
			DispatchQueue.main.async
				{
					self.startChat()
				}
		}
	}

	private var demoData: HotelBackend.StayPayload? = nil
	{
		didSet
		{
			DispatchQueue.main.async
			{
				if self.demoData != nil
				{
					self.prepareChat()
				}
				else
				{
					self.clearChat()
				}
			}
		}
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		chatSocket.delegate = self
		demoData = nil

		delegate = self
		dataSource = self
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "SetupDemo",
			let navController = segue.destination as? UINavigationController,
			let demoController = navController.viewControllers[0] as? SetupDemoViewController
		{
			demoController.doneCallback =
				{
					[weak self] demoData in self?.demoData = demoData
				}
		}

		super.prepare(for: segue, sender: sender)
	}

	@IBAction func setupDemo(_ sender: Any?)
	{
		demoData = nil
		performSegue(withIdentifier: "SetupDemo", sender: self)
	}

	private func clearChat()
	{
		inputController.isEnabled = false
		inputController.setPlaceholder("Tap “Setup” to start")

		chatMessages.removeAll()
		pendingChatMessages.removeAll()

		tableView.reloadData()
	}

	private func prepareChat()
	{
		clearChat()

		guard let demoData = self.demoData else
		{
			return
		}

		do
		{
			try AppDelegate.instance.hotelBackend.postStay(guestData: demoData)
				{
					[weak self] response in

					switch response
					{
					case .success(let stay):
						self?.guestStay = stay

					case .error(let error, let data):
						print("Could not register guest stay! \(error)")

						if let data = data
						{
							let bodyString = String(data: data, encoding: .utf8) ?? data.description
							print("Failed because: \(bodyString)")
						}
					}
				}
		}
		catch
		{
			print("Could not register guest stay! \(error)")
		}
	}

	private func startChat()
	{
		if let stay = guestStay
		{
			chatSocket.url = stay.chatSession.wssUrl
			title = "Chat Connecting"
		}
	}

	private func showAlert(message: String, title: String)
	{
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel))

		present(alert, animated: true, completion: nil)
	}
}

extension ChatViewController // Chat message management
{
	internal func insert(chatMessage: LooponChatMessage)
	{
		let newIndex = chatMessages.insertAndSort(chatMessage)
		insert(newMessages: 1, at: newIndex, scrollToBottom: true)
	}

	internal func insert(pendingChatMessage: PendingChatMessage)
	{
		pendingChatMessages.insert(pendingChatMessage, at: 0)
		insert(pendingMessages: 1, scrollToBottom: true)
	}

	internal func commit(pendingMessage: PendingChatMessage, with chatMessage: LooponChatMessage)
	{
		guard let pendingIndex = pendingChatMessages.index(of: pendingMessage) else
		{
			// Oops?
			insert(chatMessage: chatMessage)
			return
		}

		pendingChatMessages.remove(at: pendingIndex)
		let newIndex = chatMessages.insertAndSort(chatMessage)

		commitPendingMessage(with: pendingIndex, to: newIndex)
	}
}

extension ChatViewController: ChatWowDataSource
{
	func numberOfMessages(in chatController: ChatWowViewController) -> Int
	{
		return chatMessages.count
	}

	func chatController(_ chatController: ChatWowViewController, chatMessageWith index: Int) -> ChatMessage
	{
		return chatMessages[index].asChatWowMessage
	}

	func chatController(_ chatController: ChatWowViewController, readDateForMessageWith index: Int) -> Date?
	{
		return nil
	}

	func numberOfPendingMessages(in chatController: ChatWowViewController) -> Int
	{
		return pendingChatMessages.count
	}

	func chatController(_ chatController: ChatWowViewController, pendingChatMessageWith index: Int) -> ChatMessage
	{
		return pendingChatMessages[index].asChatWowMessage
	}
}

extension ChatViewController: ChatWowDelegate
{
	func chatController(_ chatController: ChatWowViewController, prepare cellView: ChatMessageView, for message: ChatMessage)
	{
		// Nothing to do in this implementation as we don't have any custom message types.
	}

	func chatController(_ chatController: ChatWowViewController, didInsertMessage message: String)
	{
		let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
		let newMessage = PendingChatMessage(content: trimmedMessage, type: .plainText)

		insert(pendingChatMessage: newMessage)

		do
		{
			try chatSocket.send(chatMessage: newMessage)

			clearInput()
		}
		catch
		{
			showAlert(message: "Could not send message: \(error)", title: "Error")
			newMessage.isFailed = true
		}
	}

	func chatController(_ chatController: ChatWowViewController, didTapMessageWith index: Int)
	{

	}

	func chatController(_ chatController: ChatWowViewController, didTapPendingMessageWith index: Int)
	{

	}

	func chatController(_ chatController: ChatWowViewController, estimatedHeightForMessageWith index: Int) -> CGFloat?
	{
		// Nothing to do in this implementation as we don't have any custom message types.
		return nil
	}
}

extension ChatViewController: LooponSocketDelegate
{
	func looponSocketDidOpen(_ looponSocket: LooponSocket)
	{
		inputController.isEnabled = true
		inputController.setPlaceholder("Type here to chat")

		print("Loopon chat socket connected!")

		title = guestStay?.guest?.name ?? "Anonymous Guest"
	}

	func looponSocket(_ looponSocket: LooponSocket, didCloseCleanly wasClean: Bool)
	{
		if wasClean
		{
			clearChat()
		}
		else
		{
			inputController.isEnabled = false
			inputController.setPlaceholder("Attempting to reconnect chat…")
		}
	}

	func looponSocket(_ socket: LooponSocket, received chatMessage: LooponChatMessage)
	{
		let localId = chatMessage.localId

		if let pendingMessage = pendingChatMessages.first(where: { $0.localId == localId })
		{
			commit(pendingMessage: pendingMessage, with: chatMessage)
		}
		else
		{
			insert(chatMessage: chatMessage)
		}
	}

	func looponSocket(_ socket: LooponSocket, received errorMessage: LooponErrorMessage)
	{

	}

	func looponSocket(_ socket: LooponSocket, received typingIndicator: LooponTypingIndicator)
	{

	}

	func looponSocket(_ socket: LooponSocket, producedError error: Error)
	{

	}
}

extension LooponChatMessage
{
	var asChatWowMessage: ChatMessage
	{
		let chatMessage: ChatMessage

		var hasError = false

		if let pending = self as? PendingChatMessage
		{
			hasError = pending.isFailed
		}

		switch self.contentType
		{
		case .plainText:
			chatMessage = ChatTextMessage(text: content ?? "",
										  side: author.side,
										  date: created.date,
										  showTimestamp: false,
										  hasError: hasError)
		default:
			// TODO: Add support for other types of messages
			chatMessage = ChatTextMessage(text: "< Content not supported >",
										  side: author.side,
										  date: created.date,
										  showTimestamp: false,
										  hasError: hasError)
		}

		return chatMessage
	}
}

extension Array where Element: Comparable
{
	mutating func insertAndSort(_ newElement: Element) -> Index
	{
		append(newElement)
		sort()
		return index(of: newElement)!
	}
}

extension LooponComposer
{
	var side: InterlocutorSide
	{
		switch self
		{
		case .guest:	return .mine
		case .hotel:	return .theirs
		}
	}
}

class PendingChatMessage: LooponChatMessage
{
	var isFailed: Bool = false
}

