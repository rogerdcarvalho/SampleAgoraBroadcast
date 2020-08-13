//
//  BroadcastViewController.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//
import UIKit
import AgoraRtcKit
import SafariServices

class BroadcastViewController: UIViewController, AgoraRtcEngineDelegate {
    
    //MARK: - Properties
    
    ///The main agora SDK object
    private lazy var agoraKit: AgoraRtcEngineKit = {
        return AgoraRtcEngineKit.sharedEngine(withAppId: Configuration.AppId, delegate: self)
    }()
    
    ///Tracks the duration of a broadcast
    private var broadcastingTimer: Timer?
    
    ///Holds the amount of seconds a broadcast has been live
    private var broadcastingTime = 0
    
    ///Holds the number of viewers currently tuned in
    //TODO: have not been able to identify where in the SDK you can keep track of the amount of viewers
    private var numberOfViewers = 0
    
    ///Keeps track if the view was previously initialized to simplify restarting a livestream after its been away from view
    private var viewInitialized = false
    
    
    ///Holds whether or not the camera is being broadcast. On change, update the UI.
    private var muteCamera = false {
        didSet {
            if (muteCamera) {
                cameraButton.setImage(camOnImage, for: .normal)
                videoView.isHidden = true
            } else {
                cameraButton.setImage(camOffImage, for: .normal)
                videoView.isHidden = false
            }
        }
    }
    
    ///Holds whether or not the microphone is being broadcast. On change, update the UI.
    private var muteSound = false{
        didSet {
            if (muteSound) {
                micButton.setImage(micOnImage, for: .normal)
            } else {
                micButton.setImage(micOffImage, for: .normal)
            }
        }
    }
    
    ///References to the various button images for camera and microphone state.
    private var camOffImage = UIImage(named: "CamOff")
    private var camOnImage = UIImage(named: "CamOn")
    private var micOffImage = UIImage(named: "MicOff")
    private var micOnImage = UIImage(named: "MicOn")
    
    //MARK: - Outlets
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var viewerCountLabel: UILabel!
    
    //MARK: - Actions
    @IBAction func cameraButtonPressed(_ sender: Any) {
        muteCamera = !muteCamera
        agoraKit.muteLocalVideoStream(muteCamera)
    }
    
    @IBAction func micButtonPressed(_ sender: Any) {
        muteSound = !muteSound
        agoraKit.muteLocalAudioStream(muteSound)
    }
    @IBAction func switchButtonPressed(_ sender: Any) {
        agoraKit.switchCamera()
    }

    //MARK: - Lifecycle
    override func viewDidLoad() {
        //To simplify UX, the app automatically assumes the user wants to start livestreaming as soon as they have tapped on 'Speaker'
        super.viewDidLoad()
        prepareUI()
        startStreaming()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Whenever the view comes back into view after having been backgrounded, restart the stream if needed
        if (self.viewInitialized) {
            startStreaming()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Whenever the user leaves the screen, assume they want to stop streaming to not waste bandwidth, battery and cpu
        endStreaming()
    }
    
    //MARK: - Local functions
    
    /**
     Displays an alert box asking the user if they want to trigger a questionnaire for all the viewers.
     */
    @objc private func askFeedback() {
        displayInput(title: "Question viewers", message: "You can trigger a questionnaire for all your viewers at any time during your broadcast. This allows you to collect personal data from your audience, gauge public opinion or ask for general feedback. \n\n Enter a SurveyMonkey® Collector Hash below to trigger your question(s) right now.", text: [Configuration.DefaultSurveyMonkeyCode], numberOfTextFields: 1, placeholderText: [Configuration.DefaultSurveyMonkeyCode]) { (results) in
            
            if (results.first != nil && results.first!.count > 0) {
                if (self.sendMessage(messageType: .Questionnaire, message: results.first!)){
                    self.displayAlert(message: "Your questionnaire has been triggered for all viewers. You can view responses in real time by logging into your SurveyMonkey® Dashboard.")
                } else {
                    self.displayAlert(message: "Your questionnaire could not be triggered. Please try again.")

                }
            }
        }
    }
    
    /**
     Terminates a livestream.
     */
    private func endStreaming(){
        // Step 1, release local AgoraRtcVideoCanvas instance
        agoraKit.setupLocalVideo(nil)
        
        // Step 2, leave channel and end group chat
        agoraKit.leaveChannel(nil)
               
        // Step 3, stop preview after leaving channel
        agoraKit.stopPreview()
        
        //Step 4, invalidate timer
        broadcastingTimer?.invalidate()
        broadcastingTime = 0
    }
    
    /**
     Sets up the UI for use
     */
    private func prepareUI(){
    
        // Improve appearance of buttons
        cameraButton.makeCircular()
        micButton.makeCircular()
        switchButton.makeCircular()
    
        // Setup the questionnaire button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action:#selector(BroadcastViewController.askFeedback))
    
    }
    
    /**
     Allows the user to send messages to all viewers currently tuned in.
     - parameter messageType: The type of message to be sent. Currently, we only support the duration of the broadcast and a SurveyMonkey questionnaire reference.
     - parameter message: The message to be sent
     */
    func sendMessage (messageType: StreamMessageType, message: String) -> Bool {
        var streamDictionary = [String: String]()
        streamDictionary[StreamMessage.MessageType.rawValue] = messageType.rawValue
        streamDictionary[StreamMessage.Data.rawValue] = message
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(streamDictionary)
            return agoraKit.sendStreamMessage(Configuration.StreamId, data: jsonData) == 0
        }catch {
            return false
        }
    }

    /**
     Starts a livestream.
     */
    private func startStreaming(){
        
        if (Configuration.Token.count == 0) {
            displayAlert(message: "Please setup a token and channel name to use this sample app. You can get these at agora.io and enter them in Configuration.swift")
            return
        }
        
        // Prepare the kit
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.broadcaster)
        agoraKit.enableVideo()

        // Prepare the UI
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0;
        videoCanvas.view = self.videoView;
        videoCanvas.renderMode = .hidden
        
        // Start stream and join channel
        agoraKit.setupLocalVideo(videoCanvas)
        agoraKit.joinChannel(byToken: Configuration.Token, channelId: Configuration.ChannelName, info: nil, uid: 0) { (string, uint, int) in
            print(string)
            print(uint)
            print(int)
            self.viewInitialized = true
        }
        
        // Open data stream to send messages
        agoraKit.createDataStream(&Configuration.StreamId, reliable: true, ordered: true)
    
    }
    
    /**
     Updates the timer on the screen with the duration of the broadcast and sends this information to all viewers tuned in.
     */
    @objc func updateTimer(){
        
        //Update duration
        broadcastingTime += 1
        
        // Determine seconds and minutes
        let minutes = Int(floor(Double(broadcastingTime) / 60))
        let seconds = broadcastingTime - (minutes * 60)
        
        // Convert values to string
        var minutesString = String(minutes)
        var secondsString = String(seconds)

        // Beautify strings
        if (minutesString.count == 1) {
            minutesString = "0" + minutesString
        }
        if (secondsString.count == 1) {
            secondsString = "0" + secondsString
        }
        let timerString = " " + minutesString + " : " + secondsString + " "
        
        // Update display
        DispatchQueue.main.async {
            self.timerLabel.text = timerString
        }
        
        // Send the broadcast duration to all viewers
        _ = sendMessage(messageType: .BroadcastTime, message: timerString)
        
    }
    
    //MARK: - AgoraRtcEngineDelegate Methods
    
    /// Occurs when the first local video frame is displayed/rendered on the local video view.
    ///
    /// Same as [firstLocalVideoFrameBlock]([AgoraRtcEngineKit firstLocalVideoFrameBlock:]).
    /// @param engine  AgoraRtcEngineKit object.
    /// @param size    Size of the first local video frame (width and height).
    /// @param elapsed Time elapsed (ms) from the local user calling the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK calls this callback.
    ///
    /// If the [startPreview]([AgoraRtcEngineKit startPreview]) method is called before the [joinChannelByToken]([AgoraRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, then `elapsed` is the time elapsed from calling the [startPreview]([AgoraRtcEngineKit startPreview]) method until the SDK triggers this callback.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        broadcastingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    /// Reports the statistics of the current call. The SDK triggers this callback once every two seconds after the user joins the channel.
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
    
    }
    
    
    /// Occurs when the first remote video frame is received and decoded.
    /// - Parameters:
    ///   - engine: AgoraRtcEngineKit object.
    ///   - uid: User ID of the remote user sending the video stream.
    ///   - size: Size of the video frame (width and height).
    ///   - elapsed: Time elapsed (ms) from the local user calling the joinChannelByToken method until the SDK triggers this callback.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        if (self.broadcastingTime < 1){
            self.navigationController?.displayAlert(message: "Someone else is already broadcasting on this app. Please pick 'Audience' to view their broadcast.")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel. Same as [userOfflineBlock]([AgoraRtcEngineKit userOfflineBlock:]).
    ///
    /// There are two reasons for users to be offline:
    ///
    /// - Leave a channel: When the user/host leaves a channel, the user/host sends a goodbye message. When the message is received, the SDK assumes that the user/host leaves a channel.
    /// - Drop offline: When no data packet of the user or host is received for a certain period of time (20 seconds for the Communication profile, and more for the Live-broadcast profile), the SDK assumes that the user/host drops offline. Unreliable network connections may lead to false detections, so Agora recommends using a signaling system for more reliable offline detection.
    ///
    ///  @param engine AgoraRtcEngineKit object.
    ///  @param uid    ID of the user or host who leaves a channel or goes offline.
    ///  @param reason Reason why the user goes offline, see AgoraUserOfflineReason.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {

    }
    
    /// Reports the statistics of the video stream from each remote user/host.
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        
    }
    
    /// Reports the statistics of the audio stream from each remote user/host.
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
        
    }
    
    /// Reports a warning during SDK runtime.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("warning code: \(warningCode.description)")
    }
    
    /// Reports an error during SDK runtime.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("warning code: \(errorCode.description)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didUpdatedUserInfo userInfo: AgoraUserInfo, withUid uid: UInt) {
        
    }
}
