# ShareNow — Flutter P2P File Sharing

📱 ShareNow – Flutter Peer-to-Peer File Sharing App

A fast, offline file-transfer app inspired by ShareIt, Xender, and SmartShare.

🚀 Overview

MyShare is a cross-platform (Flutter) file-sharing application that enables two Android devices to transfer files directly using Wi-Fi Direct / Local Hotspot, without any internet connection.

Users can instantly send and receive:

Images

Videos

Audio

Documents

ZIP/APK/Any file

The app automatically discovers nearby devices, establishes a P2P connection, and transfers files at high speed, offering a clean modern UI.

This project demonstrates:

Mobile networking

Socket programming

P2P communication

Flutter app architecture

Real-time file transfer logic

✨ Features
🔍 Device Discovery

Detect nearby devices via Wi-Fi Direct

Real-time list of devices

Connection requests with accept/reject

📤 Send Mode

Select multiple files

Preview selected files

Send request to nearby device

High-speed transfer

📥 Receive Mode

Start Wi-Fi Direct / hotspot

Wait for sender

Accept file requests

Receive multiple files

⚡ Transfer Engine

TCP socket-based transfer

Progress bar + speed + ETA

Large file support

Stable reconnection

🗂 History

Shows list of transferred files

Open files directly

Clear history

🎨 UI / UX

Modern, clean, minimal UI

Lottie animations

Dark mode

🧱 Tech Stack
Area	Technology
Framework	Flutter
Architecture	MVVM / Clean Architecture
State Management	Riverpod / Bloc
Networking	Wi-Fi Direct + TCP sockets
File Access	Flutter File Picker + Native bridging
Permissions	Storage, Wi-Fi, Location
Storage	Local JSON / SQLite
🛠 How It Works (Technical Breakdown)
1️⃣ Device Discovery

Uses Wi-Fi Direct APIs to scan for peers.

2️⃣ Connection

Sender → sends request

Receiver → accepts
Devices form a P2P group automatically.

3️⃣ Sockets

Receiver → server socket
Sender → client socket
Direct IP-to-IP connection.

4️⃣ File Transfer

Files are streamed in controlled chunks for maximum speed:

No full-file loading

Chunk-based streaming

Speed and ETA calculation

5️⃣ After Transfer

Files are stored in:

/Download/MyShare/


History is logged locally.

📸 Screenshots (Add yours later)

You can add:

Home screen

Send screen

Receive screen

Transfer UI

History screen

▶️ Getting Started
Prerequisites

Flutter SDK

Android Studio / VS Code

Two Android phones

Installation
git clone https://github.com/your-username/MyShare.git
cd MyShare
flutter pub get
flutter run

🧪 Future Enhancements

QR-code pairing

Group sharing (1-to-many / many-to-many)

LAN-based sharing (same Wi-Fi router)

Advanced compression

Share app APK directly via hotspot

💬 Interview Perspective — Is This a Strong Project?

Yes. This is an excellent interview project.

Why interviewers like it:

✔ Real-world challenges

It involves:

Sockets

Wi-Fi Direct

Multi-threading

File I/O

Cross-device communication

Error handling

Architecture patterns

Very few students build such apps.

✔ Shows deep understanding

You can discuss:

Why Wi-Fi Direct

How chunk-based transfer works

How sockets maintain reliability

How you avoided memory overload

How you handled speed optimization

✔ Unique and impressive

Everyone makes chat apps or CRUD apps.
Almost nobody makes a ShareIt/Xender-level application.

This stands out massively.

Interview Score: 9/10
🙋 Author

Subarno Singh

B.Tech IT

Passionate about mobile development and system-level programming

Interested in networking, performance optimization, and building production-ready apps

Loves learning new technologies and experimenting with real-world problem-solving
