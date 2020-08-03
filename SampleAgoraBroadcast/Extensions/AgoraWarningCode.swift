//
//  AgoraWarningCode.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//

import Foundation
import AgoraRtcKit

extension AgoraWarningCode {
    /**
    Allows warning reporting from the AgoraRTC object
    */
    var description: String {
        var text: String
        switch self {
        case .invalidView: text = "invalid view"
        default: text = "\(self.rawValue)"
        }
        return text
    }
}
