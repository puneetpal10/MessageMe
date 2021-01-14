//
//  Status.swift
//  MessageMe
//
//  Created by PuNeet on 24/12/20.
//  Copyright © 2020 dreamsteps. All rights reserved.
//

import Foundation


enum Status: String {
    case Availabel = "Availabel"
    case Busy = "Busy"
    case AtSchool = "At School"
    case AtMovie = "At Movie"
    case Atwork = "At Work"
    case BattryaboutToDie = "Battery about to die"
    case CantTalk = "Cant Talk"
    case InaMeeting = "In A Meeting"
    case AtGym = "At the Gym"
    case Sleeping = "Sleeping"
    case UrgentCall = "Urgent Calls Only"
    
    static var array: [Status]{
        var a: [Status] = []
        
        switch Status.Availabel {
        case .Availabel:
            a.append(Availabel); fallthrough
        case .Busy:
            a.append(Busy); fallthrough
        case .AtSchool:
            a.append(AtSchool); fallthrough
        case .AtMovie:
            a.append(AtMovie); fallthrough
        case .Atwork:
            a.append(Atwork); fallthrough
        case .BattryaboutToDie:
            a.append(BattryaboutToDie); fallthrough
        case .CantTalk:
            a.append(CantTalk); fallthrough
        case .InaMeeting:
            a.append(InaMeeting); fallthrough
        case .AtGym:
            a.append(AtGym); fallthrough
        case .Sleeping:
            a.append(Sleeping); fallthrough
        case .UrgentCall:
            a.append(UrgentCall);
            
            return a
            
        }
    }
}
