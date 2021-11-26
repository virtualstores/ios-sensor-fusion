// ISensorManager
// VSSensorFusion
//
// Created by CJ on 2021-11-26
// Copyright Virtual Stores - 2021
//

import Foundation
import VSFoundation


public protocol ISensorManager {
    func start()
    
    func stop()
    
    func add(delegate: ISensorManagerDelegate)
    func remove(delegate: ISensorManagerDelegate)
}

public protocol ISensorManagerDelegate {
    var id: String { get }
    func onNewMotionSensorData(data: MotionSensorData)
}
