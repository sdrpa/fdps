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

public final class FDPServer {

    private let socketServer: SocketServer

    public init(port: Int) {
        self.socketServer = SocketServer(port: port)
        self.socketServer.run()
    }

    public func broadcast(flightsUpdate: Message.FlightsUpdate) {
        guard let json = flightsUpdate.toJSON() else {
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            self.socketServer.broadcast(data)
        } catch {
            print("\(#function): \(error.localizedDescription)")
        }
    }
}
