# GuestChat

Demo App using LooponKit and ChatWow to provide a chat session for hotel guests.

---

This project is meant for Loopon partners who are embedding support for Loopon Chat into their apps. In order to use this app properly, you will need an OAuth2 client–id and secret.

If you are interested into bringing Loopon Chat into your hospitality App, contact us at [sales@loopon.com](mailto:sales@loopon.com).

If you are already a Loopon partner and are having difficulties using this demo, get in touch with us at [support@loopon.com](mailto:support@loopon.com).

## Running this Project

For this App to build and run properly, you will need to setup the `Secrets.swift` file, where you will insert the client–id and secret for the OAuth2 server. Please follow the steps below:

* Clone this project:

```shell
git clone https://github.com/LooponAB/GuestChat.git
```

* Navigate to the sources directory:

```shell
cd GuestChat/GuestChat
```

* Clone the `Secrets.example.swift` file into `Secrets.swift`:

```shell
cp Secrets.example.swift Secrets.swift
```

* Open the new `Secrets.swift` file and rename the struct to `Secrets`; then fill the placeholders with your OAuth2 client–id and secret:

```swift
struct Secrets
{
	// Example OAuth2 credentials:
	static let clientId: String		= "yadayada"
	static let clientSecret: String	= "jvUyVJb2FnDBiEY/61Ta1wYNjygtX8PHVN1FG4VBZJs="
}
```

* Compiler should finish successfully now.

## How to use this app

The App will launch into the empty chat view. To get started, tap the "Setup" button. The Guest setup view should appear.

Select a Unit by tapping the "No Unit Selected" row.

Fill in the details of the guest. The only required field is the status, or "Journey Stage", which is always pre-selected as "Pre–Stay".

When you're done, tap "Done". The app should return to the Chat view. It will then automatically register the guest and start the chat session. If it works, the title of the view will change to the authorized guest's name. If nothing happens, check the error log in Xcode.

## Important‼️

**Do not** use the `HotelBackend` class in a production environment. It is meant only to simulate the Hotel's app backend so that the App runs properly. In a real App, the Hotel's backend should register the guest stay and provide the stay object back to the App, and the App should communicate with Loopon's servers only through the chat websocket.

## License

```
BSD 3-clause License

Copyright 2017 Loopon AB

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```