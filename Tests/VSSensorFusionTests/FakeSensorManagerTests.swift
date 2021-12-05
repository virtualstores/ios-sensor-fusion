import XCTest
import VSFoundation
import Combine
@testable import VSSensorFusion

final class FakeSensorManagerTests: XCTestCase {
    
    private let fakeSensorData = [
        MotionSensorData(timestampSensor: 1,
                         timestampLocal: 2,
                         accelerationData: [],
                         gravityData: [],
                         rotationData: []),
        MotionSensorData(timestampSensor: 1,
                         timestampLocal: 2,
                         accelerationData: [],
                         gravityData: [],
                         rotationData: []),
        MotionSensorData(timestampSensor: 1,
                         timestampLocal: 2,
                         accelerationData: [],
                         gravityData: [],
                         rotationData: [])
    ]
    
    func testSetup() throws {
        let sut = FakeSensorManager(updateInterval: 1, data: fakeSensorData, repeats: false)
        
        XCTAssertFalse(sut.isRunning)
        XCTAssertNil(sut.sensorPublisher.value)
        XCTAssertNoThrow(try sut.start())
        sut.stop()
    }
    
    func testSendingFakeValues() throws {
        let sut = FakeSensorManager(updateInterval: 1, data: fakeSensorData, repeats: false)
        
        let expectation = self.expectation(description: "Awaiting publisher")
        let cancellable = sut.sensorPublisher
            .compactMap { $0 }
            .collect(3)
            .sink { _ in } receiveValue: { data in
            expectation.fulfill()
        }

        try sut.start()
        waitForExpectations(timeout: 3)
        cancellable.cancel()
    }
}
