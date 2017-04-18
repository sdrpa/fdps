/**
 Created by Sinisa Drpa on 3/31/17.

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
import Measure

extension Flight: Coding {

    public init?(json: JSON) {
        guard let callsign: String = "callsign" <| json,
            let squawk: Squawk = "squawk" <| json,
            let mach: Mach = "mach" <| json,
            let heading: Degree = "heading" <| json,
            let position: Position = "position" <| json,
            let flightPlan: FlightPlan = "flightPlan" <| json else {
                return nil
        }
        self.callsign = callsign
        self.squawk = squawk
        self.mach = mach
        self.heading = heading
        self.position = position
        self.flightPlan = flightPlan
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "callsign" |> self.callsign,
            "squawk" |> self.squawk,
            "mach" |> self.mach,
            "heading" |> self.heading,
            "position" |> self.position,
            "flightPlan" |> self.flightPlan
            ])
    }
}
