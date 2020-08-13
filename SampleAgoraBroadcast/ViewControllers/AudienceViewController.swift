//
//  AudienceViewController.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//

import UIKit
import AgoraRtcKit

class AudienceViewController: UIViewController, AgoraRtcEngineDelegate, SMFeedbackDelegate {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var streamView: UIView!
    
    //MARK: - Properties

    ///The main agora SDK object
    private lazy var agoraKit: AgoraRtcEngineKit = {
        return AgoraRtcEngineKit.sharedEngine(withAppId: Configuration.AppId, delegate: self)
    }()
    
    ///Keeps track if the view was previously initialized to simplify restarting a livestream after its been away from view
    private var viewInitialized = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        //To simplify UX, the app automatically assumes the user wants to start viewing an active livestream as soon as they have tapped on 'Audience'
        super.viewDidLoad()
        receiveStream()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Whenever the view comes back into view after having been backgrounded, restart the stream if needed
        if (self.viewInitialized) {
            receiveStream()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Whenever the user leaves the screen, assume they want to stop receiving stream to not waste bandwidth, battery and cpu
        endStreaming()
    }
    
    //MARK: - Local functions
    
    /**
     Terminates a livestream.
     */
    private func endStreaming(){
        // Step 1, release local AgoraRtcVideoCanvas instance
        agoraKit.setupLocalVideo(nil)
        
        // Step 2, leave channel and end group chat
        agoraKit.leaveChannel(nil)
    }
    
    /**
     Connects to an existing livestream.
     */
    private func receiveStream(){
        
        if (Configuration.Token.count == 0) {
            displayAlert(message: "Please setup a token and channel name to use this sample app. You can get these at agora.io and enter them in Configuration.swift")
            return
        }
        
        // Prepare the kit
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.audience)
        agoraKit.enableVideo()
        
        agoraKit.joinChannel(byToken: Configuration.Token, channelId: Configuration.ChannelName, info: nil, uid: 0) { (string, uint, int) in
            print(string)
            print(uint)
            print(int)
            
            self.viewInitialized = true

        }
    }
    
    /**
     Triggers the display of a SurveyMonkey Questionnaire
     - parameter code: The SurveyMonkey Collector Hash that identifies the specific questionnaire to be triggered
     */
    private func displaySurvey(code: String){
        let feedbackController = SMFeedbackViewController(survey: code)
        feedbackController?.present(from: self, animated: true, completion: nil)
    }
    
    //MARK: - SurveyMonkey SMFeedbackDelegate Methods
    
    func respondentDidEndSurvey(_ respondent: SMRespondent!, error: Error!) {
        //Irrelevant for this use case.
        
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
        
        // Put remote stream into UIView
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid;
        videoCanvas.view = self.streamView;
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
        
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
    
    /// Receives messages from the host
    func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        
        do {

            let decoded = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let streamMessage = decoded as? [String:String] {
                if (streamMessage[StreamMessage.MessageType.rawValue] == StreamMessageType.BroadcastTime.rawValue) {
                    //The message received was an update on the time the broadcast has been playing
                    if let time = streamMessage[StreamMessage.Data.rawValue] {
                        DispatchQueue.main.async {
                            self.timerLabel.text = time
                            self.timerLabel.isHidden = false
                        }
                    }
                } else if (streamMessage[StreamMessage.MessageType.rawValue] == StreamMessageType.Questionnaire.rawValue) {
                    // The message received was a request to trigger a SurveyMonkey Questionnaire
                    if let surveyCode = streamMessage[StreamMessage.Data.rawValue] {
                        DispatchQueue.main.async {
                            self.displaySurvey(code: surveyCode)
                        }
                    }
                }
            }
        } catch {
            print("Error with message received: " + error.localizedDescription)
        }
    }
    
}
