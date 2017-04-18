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
import JSON

public protocol Messageable  {
    var messageType: MessageType { get }
}

public enum MessageType: Int {
    case flightsUpdate
    case airspaceUpdate
}

public struct Message {

    public struct FlightsUpdate: Messageable {

        public let messageType: MessageType
        public let flights: [Flight]

        public init(messageType: MessageType = .flightsUpdate, flights: [Flight]) {
            self.messageType = messageType
            self.flights = flights
        }
    }
}

extension Message.FlightsUpdate: Coding {

    public init?(json: JSON) {
        guard let messageType: MessageType = "messageType" <| json,
            let flights: [Flight] = "flights" <| json else {
                return nil
        }
        self.messageType = messageType
        self.flights = flights
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "messageType" |> self.messageType,
            "flights" |> self.flights
            ])
    }
}
