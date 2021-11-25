import CoreMotion
import Foundation
import VSFoundation


public protocol SensorManager {
    func start()
    
    func stop()
    
    func addDelegate(delegate: SensorManagerDelegate)
    func removeDelegate(delegate: SensorManagerDelegate)
}

public protocol SensorManagerDelegate {
    var id: String { get }
    func onNewMotionSensorData(data: MotionSensorData)
}

public class SensorManagerImpl: SensorManager {

    private let INTERVAL_100hz = 1.0 / 100.0
    private let GRAVITY = 9.81
        
    private let motion: CMMotionManager
    private let sensorOperation = OperationQueue()
    private let serialDispatch: DispatchQueue = DispatchQueue(label: "se.tt2.sensorManager")
    
    private var isRunning: Bool = false
    
    private var delegates: [String:SensorManagerDelegate] = [:]
    
    public init() {
        self.motion = CMMotionManager()
    }
    
    public func start() {
        if self.isRunning {
            return
        }
        
        self.isRunning = true
        
        if self.motion.isDeviceMotionAvailable {
            self.motion.startDeviceMotionUpdates(to: self.sensorOperation) { [self] (data, error) in
                if let validData = data {
                    
                    let timestampSensor = Int(validData.timestamp * 1000)
                    let timestampLocal = Int(Date().timeIntervalSince1970 * 1000)
                    
                    var accelerationData: [Float] = [Float](repeating: 0, count: 3)
                    accelerationData[0] = Float(validData.userAcceleration.x * GRAVITY)
                    accelerationData[1] = Float(validData.userAcceleration.y * GRAVITY)
                    accelerationData[2] = Float(validData.userAcceleration.z * GRAVITY)
                    
                    var gravityData: [Float] = [Float](repeating: 0, count: 3)
                    gravityData[0] = Float(validData.gravity.x * -GRAVITY)
                    gravityData[1] = Float(validData.gravity.y * -GRAVITY)
                    gravityData[2] = Float(validData.gravity.z * -GRAVITY)
                    
                    var rotationData: [Float] = [Float](repeating: 0, count: 4)
                    rotationData[0] = Float(validData.attitude.quaternion.x)
                    rotationData[1] = Float(validData.attitude.quaternion.y)
                    rotationData[2] = Float(validData.attitude.quaternion.z)
                    rotationData[3] = Float(validData.attitude.quaternion.w)
                    
                    self.notifyMotionSensorDataUpdate(
                        data: MotionSensorData(
                            timestampSensor: timestampSensor,
                            timestampLocal: timestampLocal,
                            accelerationData: accelerationData,
                            gravityData: gravityData,
                            rotationData: rotationData
                        )
                    )
                }
            }
        }
    }
    
    private func notifyMotionSensorDataUpdate(data: MotionSensorData){
        delegates.forEach { $1.onNewMotionSensorData(data: data) }
    }
    
    public func stop() {
        self.motion.stopDeviceMotionUpdates()
        self.isRunning = false
    }
    
    public func addDelegate(delegate: SensorManagerDelegate) {
        delegates[delegate.id] = delegate
    }
    
    public func removeDelegate(delegate: SensorManagerDelegate) {
        delegates.removeValue(forKey: delegate.id)
    }
}
