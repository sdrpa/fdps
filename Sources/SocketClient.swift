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

import Foundation
import Socket
import Dispatch

final class SocketClient {

    fileprivate let bufferSize = 4096
    fileprivate let port: Int32
    fileprivate let server: String
    fileprivate var socket: Socket?

    init(server: String, port: Int32) {
        self.server = server
        self.port = port
    }

    deinit {
        sleep(1) // Be nice to the server
        self.socket?.close()
    }

    /**
     Run the client on the background thread

    - parameter closure: A closure that will be called on the main thread whenever data is received.
     */
    func run(_ closure: @escaping (Data) -> Void) {
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async { [unowned self] in
            do {
                self.socket = try Socket.create()
                guard let socket = self.socket else {
                    print("Unable to create socket.")
                    return
                }
                try socket.connect(to: self.server, port: self.port)
                print("Connected to: \(socket.remoteHostname):\(socket.remotePort)")

                var shouldKeepRunning = true
                var readData = Data(capacity: socket.readBufferSize)
                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    guard bytesRead > 0 else {
                        shouldKeepRunning = false
                        return
                    }
                    DispatchQueue.main.sync {
                        closure(readData)
                    }
                    readData.count = 0
                } while shouldKeepRunning
            }
            catch {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error.")
                    return
                }
                print("Error:\n\(socketError.description)")
            }
        }
    }
}
