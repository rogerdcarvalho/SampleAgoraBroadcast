# SampleAgoraBroadcast
A simple proof-of-concept app using the Agora.io Live Interactive Video Streaming SDK in combination with SurveyMonkey. This app can be used to live broadcast video to up to 17 viewers while also being able to ask them to complete advanced questionnaires during broadcast.

## Introduction
This is a simple Xcode project for iPhone and iPad. It uses the [Agora Live Interactive Video Streaming SDK](https://docs.agora.io/en/Interactive%20Broadcast/start_live_ios?platform=iOS) to enable a user to broadcast a live video stream to up to 17 viewers. Whenever users open this app, they can choose to be either a 'Speaker' or an 'Audience' member. As a 'Speaker', they instantly start broadcasting their video and microphone to other users of the app. When a user opens the app as an 'Audience' member, the app simply waits for someone to start broadcasting as 'Speaker' and then displays their live stream. Speakers can trigger [SurveyMonkey](https://github.com/SurveyMonkey/surveymonkey-ios-sdk) questionnaires for all viewers of their stream whenever they want to ask viewers for feedback or information. SurveyMonkey supports dozens of question formats and polls. Their web dashboard updates in real time, so this allows 'Speakers' to ask their viewers a plethora of questions during their live stream while being able to view and analyze the responses instantly as they occur during the broadcast. 

![screenshot 1](https://rogerdcarvalho.com/agorahome.jpg "One-click livestreaming")
![screenshot 2](https://rogerdcarvalho.com/agorasurvey.jpg "Trigger surveys during broadcast")
![screenshot 3](https://rogerdcarvalho.com/agorasurvey2.jpg "Users respond instantly")
![screenshot 4](https://rogerdcarvalho.com/surveymonkey.jpg "Analyze results in real time")

## Instructions
Clone this repository to your local machine. This repository requires [CocoaPods](https://cocoapods.org). Terminal into the root folder of the project and run `pod install`. Then open `SampleAgoraBroadcast.xcworkspace`. Click on the `SampleAgoraBroadcast` project and then on `Signing & Capabilities`. Check `Automatically Manage Signing` and select any team that works for your Xcode installation. 

You should now be able to run the SampleAgoraBroadcast target on an iPad or iPhone. Running this project in a simulator is NOT supported. The app is configured with a working configuration so it should function right out of the box. If you however wish to use any of the source code for your own project, please open `Configuration.swift` under `Supporting Files` and change the `AppId`, `ChannelName` and `Token` to your own keys. You can get these for free at https://sso.agora.io/v2/signup.

## How it works
The app has 3 ViewControllers. One for the launch screen, and then one for a 'Speaker' user and one for an 'Audience' user. It is configured via a Configuration sctruct that is located under 'Supporting Files'. There are a couple of helper classes and extensions that simplify certain actions. All files are extensively documented.

* **BroadcastViewController:** This is the ViewController that handles the 'Speaker' experience. It automatically connects to the Agora.io SDK using the AppId, Channelname and Token stored in the `Configuration.swift` file. It then starts streaming video and audio. The user can disable video and/or microphone and switch the active camera using the buttons on the screen. They can also trigger a SurveyMonkey questionnaire for all viewers using the right bar button (this only works if at least 1 viewer is connected and viewing the stream, otherwise it will trigger an error message). The ViewController keeps track of how long the user has been broadcasting and sends this duration to all viewers so they know how long the stream has been live already when they tune in.

* **AudienceViewController:** This is the ViewController that handles the 'Audience' experience. It automatically connects to the Agora.io SDK using the AppId, ChannelName and Token stored in the `Configuration.swift` file. If there is a 'Speaker' actively broadcasting it will display their stream and how long they have been broadcasting. Otherwise it will wait for a 'Speaker' to connect. Whenever a 'Speaker' triggers a SurveyMonkey questionnaire, it will temporarily end the video stream, display the questionnaire, and restart the stream whenever the user has answered the questions or dismissed the questionnaire.

The other files simply support the functionality of these two main ViewControllers. It should all be pretty straightforward to understand.

## Notes
This library has only been tested on iOS 13. It is however expected to work on any device running iOS 8.0 or later.

