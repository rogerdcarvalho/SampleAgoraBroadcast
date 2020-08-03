//
//  StreamMessageType.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//

import Foundation

/**
 Offers  the different types of messages the host can send to the audience
 */
enum StreamMessageType: String {
    case BroadcastTime = "broadcast_time"
    case Questionnaire = "questionnaire"
}
