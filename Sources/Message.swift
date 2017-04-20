/**
 Created by Sinisa Drpa on 4/18/17.

 FDPS is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License or any later version.

 FDPS is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with FDPS.  If not, see <http://www.gnu.org/licenses/>
 */

import ATCKit
import Foundation
import JSON

public protocol Messageable  {
    var messageType: MessageType { get }
    var timestamp: TimeInterval { get }
}

public enum MessageType: Int {
    case flightsUpdate
    case airspaceUpdate
}

public struct Message {

    public struct FlightsUpdate: Messageable, Equatable {

        public let messageType: MessageType
        public let timestamp: TimeInterval
        public let flights: [Flight]

        public init(messageType: MessageType = .flightsUpdate,
                    timestamp: TimeInterval,
                    flights: [Flight]) {
            self.messageType = messageType
            self.timestamp = timestamp
            self.flights = flights
        }

        public static func ==(lhs: FlightsUpdate, rhs: FlightsUpdate) -> Bool {
            return lhs.messageType == rhs.messageType &&
                lhs.timestamp == rhs.timestamp &&
                lhs.flights == rhs.flights
        }
    }
}

extension Message.FlightsUpdate: Coding {

    public init?(json: JSON) {
        guard let messageType: MessageType = "messageType" <| json,
            let timestamp: TimeInterval = "timestamp" <| json,
            let flights: [Flight] = "flights" <| json else {
                return nil
        }
        self.messageType = messageType
        self.timestamp = timestamp
        self.flights = flights
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "messageType" |> self.messageType,
            "timestamp" |> self.timestamp,
            "flights" |> self.flights
            ])
    }
}
