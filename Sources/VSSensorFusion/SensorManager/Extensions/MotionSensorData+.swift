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

        let accelerationData = [Float(data.userAcceleration.x * gravity),
                                Float(data.userAcceleration.y * gravity),
                                Float(data.userAcceleration.z * gravity)]

        let gravityData = [Float(data.gravity.x * -gravity),
                           Float(data.gravity.y * -gravity),
                           Float(data.gravity.z * -gravity)]

        let rotationData = [Float(data.attitude.quaternion.x),
                            Float(data.attitude.quaternion.y),
                            Float(data.attitude.quaternion.z),
                            Float(data.attitude.quaternion.w)]
        
        self.init(timestampSensor: timestampSensor,
                  timestampLocal: timestampLocal,
                  accelerationData: accelerationData,
                  gravityData: gravityData,
                  rotationData: rotationData)
    }
}
