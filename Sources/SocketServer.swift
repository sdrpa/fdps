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

import Dispatch
import Foundation
import Socket

final class SocketServer {

    fileprivate static let bufferSize = 4096

    fileprivate let port: Int
    fileprivate var listenSocket: Socket?
    fileprivate var connectedSockets = [Int32: Socket]()
    fileprivate let socketLockQueue = DispatchQueue.global()
    fileprivate let dispatchQueue = DispatchQueue.global()
    fileprivate var continueRunning = true

    init(port: Int) {
        self.port = port
    }

    deinit {
        self.listenSocket?.close()
        for socket in self.connectedSockets.values {
            socket.close()
        }
    }

    func run() {
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async { [unowned self] in
            do {
                try self.listenSocket = Socket.create()
                guard let socket = self.listenSocket else {
                    print("Unable to create socket.")
                    return
                }
                try socket.listen(on: self.port)
                print("Listening on port: \(socket.listeningPort)")

                repeat {
                    let newSocket = try socket.acceptClientConnection()
                    print("Accepted connection from \(newSocket.remoteHostname):\(newSocket.remotePort)")
                    //print("Socket Signature: \(newSocket.signature?.description)")
                    self.addNewConnection(socket: newSocket)
                } while self.continueRunning
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error.")
                    return
                }
                if self.continueRunning {
                    print("Error:\n \(socketError.description)")
                }
            }
        }
    }

    func addNewConnection(socket: Socket) {
        // Add the new socket to the list of connected sockets
        self.socketLockQueue.sync { [unowned self, socket] in
            self.connectedSockets[socket.socketfd] = socket
        }
        self.dispatchQueue.async { [unowned self, socket] in
            var shouldKeepRunning = true
            var readData = Data(capacity: SocketServer.bufferSize)
            do {
                try socket.write(from: "Hello, type 'QUIT' to end session\n")

                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    if bytesRead > 0 {
                        guard let query = String(data: readData, encoding: .utf8) else {
                            print("Error decoding response:\n\(readData)")
                            readData.count = 0
                            break
                        }
                        print("Received from \(socket.remoteHostname):\(socket.remotePort) \(query.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))")
                        if query == Command.quit.rawValue {
                            try socket.write(from: "Bye!\n")
                            shouldKeepRunning = false
                        } else {
                            try self.respond(to: socket, query: query)
                        }
                    }
                    if bytesRead == 0 {
                        shouldKeepRunning = false
                        break
                    }
                    readData.count = 0
                } while shouldKeepRunning

                socket.close()
                self.socketLockQueue.sync { [unowned self, socket] in
                    self.connectedSockets[socket.socketfd] = nil
                }
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort).")
                    return
                }
                if self.continueRunning {
                    print("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description).")
                }
            }
        }
    }

    func broadcast(_ data: Data) {
        self.dispatchQueue.async { [unowned self] in
            for socket in self.connectedSockets.values {
                do {
                    if socket.isActive {
                        try socket.write(from: data)
                    } else {
                        socket.close()
                        self.socketLockQueue.sync { [unowned self, socket] in
                            self.connectedSockets[socket.socketfd] = nil
                        }
                    }
                } catch let error {
                    print("Broadcast error: \(error)")
                }
            }
        }
    }
}

fileprivate extension SocketServer {

    fileprivate enum Command: String {
        case quit = "QUIT"
    }

    fileprivate func respond(to socket: Socket, query: String) throws {
        let reply = "Server response: \(query)"
        try socket.write(from: reply)
    }
}
