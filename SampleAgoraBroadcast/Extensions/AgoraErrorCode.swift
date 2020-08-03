//
//  AgoraErrorCode.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//

import Foundation
import AgoraRtcKit

extension AgoraErrorCode {
    /**
    Allows error reporting from the AgoraRTC object
    */
    var description: String {
        var text: String
        switch self {
        case .joinChannelRejected: text = "join channel rejected"
        case .leaveChannelRejected: text = "leave channel rejected"
        case .invalidAppId: text = "invalid app id"
        case .invalidToken: text = "invalid token"
        case .invalidChannelId: text = "invalid channel id"
        default: text = "\(self.rawValue)"
        }
        return text
    }
}
