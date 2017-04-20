/**
 Created by Sinisa Drpa on 2/18/17.

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

public final class FDPClient {

    private let socketClient: SocketClient

    public var flightsUpdate: ((Message.FlightsUpdate) -> Void)?

    public init(server: String, port: Int) {
        self.socketClient = SocketClient(server: server, port: Int32(port))
        self.socketClient.run { [weak self] readData in
            guard let jsonObject = try? JSONSerialization.jsonObject(with: readData, options: []) else {
                return
            }
            //print("jsonObject: \(jsonObject)\n\(Date())")
            guard let json = jsonObject as? JSON,
                let rawValue = json["messageType"] as? Int,
                let messageType = MessageType(rawValue: rawValue) else {
                    return
            }
            switch messageType {
            case .flightsUpdate:
                guard let message = Message.FlightsUpdate(json: json) else {
                    return
                }
                self?.flightsUpdate?(message)
            case .airspaceUpdate:
                print("Received airspace update")
            }
        }
    }
}
