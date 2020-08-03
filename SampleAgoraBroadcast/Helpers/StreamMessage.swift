//
//  StreamMessage.swift
//  SampleAgoraBroadcast
//
//  Created by Roger Carvalho on 03/08/2020.
//  Copyright © 2020 Roger Carvalho. All rights reserved.
//

import Foundation

/**
 Holds the dictionary keys for messages sent between host and audience
 */
enum StreamMessage: String {
    case MessageType = "type"
    case Data = "data"
}
