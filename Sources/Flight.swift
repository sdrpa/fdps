/**
 Created by Sinisa Drpa on 4/8/17.

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
import Measure

/**
 * Represents the data caculated by FDPS
 */
public struct Flight: Equatable {

    public let callsign: String
    public let squawk: Squawk
    public let position: Position
    public let mach: Mach
    public let heading: Degree
    public let flightPlan: FlightPlan?

    public init(mode: Transponder.modeSEHS) {
        self.init(callsign: mode.callsign, squawk: mode.squawk, position: mode.position, mach: mode.mach, heading: mode.heading, flightPlan: nil)
    }

    public init(callsign: String, squawk: Squawk = 2000, position: Position, mach: Mach, heading: Degree, flightPlan: FlightPlan?) {
        self.callsign = callsign
        self.squawk = squawk
        self.position = position
        self.mach = mach
        self.heading = heading
        self.flightPlan = flightPlan
    }

    public static func ==(lhs: Flight, rhs: Flight) -> Bool {
        return (lhs.callsign == rhs.callsign) && (lhs.squawk == rhs.squawk)
    }
}

extension Flight {

    public var flightLevel: FL {
        return FL(position.altitude)
    }
}
