# LooponKit

## iOS Library for Loopon's Public API

This library contains models, connectors, and helper functions that allow an iOS App to easily communicate with Loopon's Public API.

[**Loopon's Public API Documentation**](https://api.loopon.com/public)

## Contents

* Model classes for API objects.
* LooponSocket: Helper class to connect to the Loopon Chat websocket.

## Examples

### Creating a Guest Stay

Your application should communicate with your backend, which in turn should talk to Loopon's backend to produce a guest stay (read more in the api documentation). After that is done, your application's backend should push the Guest Stay JSON object back to your app. You can decode the JSON yourself, if you wish, but LooponKit can do it for you in one line. The encoded JSON object as `Data` is represented by `guestStayJsonData` below:

```swift
func gotStay(_ guestStayJsonData: Data)
{
	do
	{
		self.guestStay = try JSONDecoder().decode(LooponGuestStay.self, from: guestStayJsonData)
	}
	catch
	{
		print("Error decoding guest stay JSON: \(error)")
	}
}
```

### LooponSocket

After you have the guest stay stored locally, you can start sending messages. For that, simply instantiate a `LooponSocket` object, set the delegate who will receive calls when messages arrive, and set the socket URL to connect to. The URL can be found in the guest stay object:

```swift
func buildSocket()
{
	// This should ideally be a class property, as you only need a single instance.
	self.chatSocket = LooponSocket()
	self.chatSocket.delegate = self
	
	// This will cause the chat socket to connect automatically.
	self.chatSocket.url = self.guestStay.chatSession.wssUrl
}

// MARK: Chat Socket Delegate methods:

/// Sent when the socket connects successfully.
func looponSocketDidOpen(_ looponSocket: LooponSocket)
{
	print("Socket opened!")
}

/// Sent when the socket closes. If this was caused by an error or timeout, `didCloseCleanly` will be `false`, and
/// LooponSocket will automatically attempt to reopen the connection.
/// If this succeeds, another call to `looponSocketDidOpen:` will be made.
func looponSocket(_ looponSocket: LooponSocket, didCloseCleanly: Bool)
{
	print("Socket closed!")
}

/// Sent when a message is received through the socket.
func looponSocket(_ socket: LooponSocket, received chatMessage: LooponChatMessage)
{
	print("Got chat message from \(chatMessage.authorName): \(chatMessage.content ?? "")")
}

/// Sent when an error message is received through the socket.
func looponSocket(_ socket: LooponSocket, received errorMessage: LooponErrorMessage)
{
	print("Socket got error: \(errorMessage)!")
}

/// Sent when a typing indicator is received through the socket.
func looponSocket(_ socket: LooponSocket, received typingIndicator: LooponTypingIndicator)
{
	print("Socket got typing indicator: \(typingIndicator)!")
}

/// Sent when a runtime error happens.
func looponSocket(_ socket: LooponSocket, producedError error: Error)
{
	print("Socket got runtime error: \(error)!")
}

```

The difference between `looponSocket:receivedErrorMessage:` and `looponSocket:producedError:` is that the first is called when an error is sent from the server, and the second when an error is produced locally.

### Sending messages

To send a message from your app, create a `LooponChatMessage` object locally, and send it using the `sendChatMessage:` method on the chat socket:

```swift
func sendMessage(_ text: String)
{
	let trimmedMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)
	let message = LooponChatMessage(content: trimmedMessage, type: .plainText)
	
	do
	{
		try self.chatSocket.send(chatMessage: message)
	}
	catch
	{
		print("Error sending chat message: \(error)")
	}
}
```

You should display the message as "pending" to the user, for now.

If and when the message is sent successfully, you will receive it back in the socket through the `looponSocket:receivedChatMessage:` delegate method. Only then you should "commit" the message in the UI, and store it locally if you are going to cache messages locally.

## License

```
Copyright © 2017 Loopon AB

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```