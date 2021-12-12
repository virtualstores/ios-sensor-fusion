//
// MotionSensorData+
// VSSensorFusion
//
// Created by Karl Söderberg on 2021-12-05
// Copyright Virtual Stores - 2021
//

import Foundation
import CoreMotion
import VSFoundation

extension MotionSensorData {
    
    private static var gravity: Double { 9.81 }

    init(data: CMDeviceMotion) {
        let gravity = Self.gravity
        
        let timestampSensor = Int(data.timestamp * 1000)
        let timestampLocal = Int(Date().timeIntervalSince1970 * 1000)

        let accelerationData = [data.userAcceleration.x * gravity,
                                data.userAcceleration.y * gravity,
                                data.userAcceleration.z * gravity]

        let gravityData = [data.gravity.x * -gravity,
                           data.gravity.y * -gravity,
                           data.gravity.z * -gravity]

        let rotationData = [data.attitude.quaternion.x,
                            data.attitude.quaternion.y,
                            data.attitude.quaternion.z,
                            data.attitude.quaternion.w]
        
        self.init(timestampSensor: timestampSensor,
                  timestampLocal: timestampLocal,
                  accelerationData: accelerationData,
                  gravityData: gravityData,
                  rotationData: rotationData)
    }
}
