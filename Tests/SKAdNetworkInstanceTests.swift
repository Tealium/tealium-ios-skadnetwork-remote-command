import XCTest
@testable import TealiumSKAdNetwork


class CallbackDelegate: SKAdNetworkConversionDelegate {
    
    var onUpdateCallback: (ConversionData, Bool) -> ()
    var onCompletedCallback: (Error?) -> ()
    init(onConversionUpdate: @escaping (ConversionData, Bool) -> (),
         onConversionUpdateCompleted: @escaping (Error?) -> ()) {
        self.onUpdateCallback = onConversionUpdate
        self.onCompletedCallback = onConversionUpdateCompleted
    }
    
    func onConversionUpdate(conversionData: ConversionData, lockWindow: Bool) {
        onUpdateCallback(conversionData, lockWindow)
    }
    
    func onConversionUpdateCompleted(error: Error?) {
        onCompletedCallback(error)
    }
}

@available(iOS 11.3, *)
extension SKAdNetworkInstance {
    func updateConversionData(_ data: ConversionData) {
        updateConversionData(fineValue: data.fineValue, coarseValue: data.coarseValue)
    }
}

@available(iOS 11.3, *)
class SKAdNetworkInstanceTests: XCTestCase {
    let instance = SKAdNetworkInstance(conversionDelegate: nil)
    
    func testInitialize() {
        instance.initialize(configuration: SKAdNetworkConfiguration(sendHigherValue: true))
        XCTAssertTrue(instance.configuration.sendHigherValue)
    }
    
    func testReadFromStorage() {
        let userDefault = UserDefaults(suiteName: "test.skad")
        let data = ConversionData(fineValue: 100, coarseValue: .high)
        userDefault?.conversionData = data
        let instance = SKAdNetworkInstance(conversionDelegate: nil, userDefaults: userDefault)
        XCTAssertEqual(instance.conversionData, data)
        userDefault?.removeObject(forKey: userDefault!.conversionDataKey)
    }
    
    func testUpdateConversionData() {
        let data = ConversionData(fineValue: 10, coarseValue: .medium)
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: false)
        instance.updateConversionData(data)
        XCTAssertEqual(instance.conversionData, data)
        let lowerData = ConversionData(fineValue: 9, coarseValue: .low)
        instance.updateConversionData(lowerData)
        XCTAssertNotEqual(instance.conversionData, data)
        XCTAssertEqual(instance.conversionData, lowerData)
    }

    func testUpdateConversionDataWithSendHigherValue() {
        let data = ConversionData(fineValue: 10, coarseValue: .medium)
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: true)
        instance.updateConversionData(data)
        XCTAssertEqual(instance.conversionData, data)
        let lowerData = ConversionData(fineValue: 9, coarseValue: .low)
        instance.updateConversionData(lowerData)
        XCTAssertEqual(instance.conversionData, data)
        XCTAssertNotEqual(instance.conversionData, lowerData)
    }
    
    func testShouldUpdateFineValueEqual() {
        instance.updateConversionData(ConversionData(fineValue: 10, coarseValue: .medium))
        XCTAssertTrue(instance.shouldUpdateFineValue(10))
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: true)
        XCTAssertFalse(instance.shouldUpdateFineValue(10))
    }
    
    func testShouldUpdateFineValueHigher() {
        instance.updateConversionData(ConversionData(fineValue: 10, coarseValue: .medium))
        XCTAssertTrue(instance.shouldUpdateFineValue(11))
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: true)
        XCTAssertTrue(instance.shouldUpdateFineValue(11))
    }
    
    func testShouldUpdateFineValueLower() {
        instance.updateConversionData(ConversionData(fineValue: 10, coarseValue: .medium))
        XCTAssertTrue(instance.shouldUpdateFineValue(9))
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: true)
        XCTAssertFalse(instance.shouldUpdateFineValue(9))
    }
    
    func testShouldUpdateCoarseValueEqual() {
        instance.updateConversionData(ConversionData(fineValue: 10, coarseValue: .medium))
        XCTAssertTrue(instance.shouldUpdateCoarseValue(.medium))
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: true)
        XCTAssertFalse(instance.shouldUpdateCoarseValue(.medium))
    }
    
    func testShouldUpdateCoarseValueHigher() {
        instance.updateConversionData(ConversionData(fineValue: 10, coarseValue: .medium))
        XCTAssertTrue(instance.shouldUpdateCoarseValue(.high))
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: true)
        XCTAssertTrue(instance.shouldUpdateCoarseValue(.high))
    }
    
    func testShouldUpdateCoarseValueLower() {
        instance.updateConversionData(ConversionData(fineValue: 10, coarseValue: .medium))
        XCTAssertTrue(instance.shouldUpdateCoarseValue(.low))
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: true)
        XCTAssertFalse(instance.shouldUpdateCoarseValue(.low))
    }
    
    func testResetConversionData() {
        let defaultConversionData = ConversionData(fineValue: 0)
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: false)
        instance.updateConversionData(ConversionData(fineValue: 10, coarseValue: .medium))
        instance.resetConversionData()
        XCTAssertEqual(instance.conversionData, defaultConversionData)
    }
    
    func testResetConversionDataWithSendHigherValue() {
        let defaultConversionData = ConversionData(fineValue: 0)
        instance.configuration = SKAdNetworkConfiguration(sendHigherValue: true)
        instance.updateConversionData(ConversionData(fineValue: 10, coarseValue: .medium))
        instance.resetConversionData()
        XCTAssertEqual(instance.conversionData, defaultConversionData)
    }
    
    func testUpdatePostbackConversionValue() {
        let data = ConversionData(fineValue: 5, coarseValue: .medium)
        let conversionExpectation = expectation(description: "Conversion update completed")
        let callbackDelegate = CallbackDelegate { data, lockWindow in
            XCTAssertEqual(self.instance.conversionData, data)
            XCTAssertTrue(lockWindow)
        } onConversionUpdateCompleted: { error in
            conversionExpectation.fulfill()
        }
        instance.conversionDelegate = callbackDelegate
        instance.updateConversionData(fineValue: data.fineValue, coarseValue: data.coarseValue)
        instance.updatePostbackConversionValue(lockWindow: true)
        waitForExpectations(timeout: 3.0)
    }
}
