//
//  TealiumHelper.swift
//  iOSTealiumTest
//
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation
import TealiumSwift
import TealiumSKAdNetwork
import SwiftUI

class TealiumHelper: SKAdNetworkConversionDelegate, ObservableObject {
    func onConversionUpdate(conversionData: ConversionData, lockWindow: Bool) {
        DispatchQueue.main.async {
            self.conversion = conversionData
        }
    }
    
    func onConversionUpdateCompleted(error: Error?) {
        
    }
    

    @ToAnyObservable(TealiumBufferedSubject(bufferSize: 10))
    var onWillTrack: TealiumObservable<[String:Any]>
    
    static let shared = TealiumHelper()
    var tealium: Tealium?
    var enableHelperLogs = true
    @Published var conversion: ConversionData?

    private init() { }

    func start() {
        let config = TealiumConfig(account: "tealiummobile",
                                   profile: "demo",
                                   environment: "prod",
                                   dataSource: "test12",
                                   options: nil)

        config.connectivityRefreshInterval = 5
        config.loggerType = .os
        config.logLevel = .info
        config.consentLoggingEnabled = true
//        config.remoteHTTPCommandDisabled = false
        config.dispatchListeners = [self]
        config.shouldUseRemotePublishSettings = false
        config.remoteAPIEnabled = true
        config.collectors = [
            Collectors.Lifecycle
        ]
        config.dispatchers = [
                Dispatchers.Collect,
//                Dispatchers.TagManagement,
                Dispatchers.RemoteCommands
            ]
        let skadCommand = SKAdNetworkRemoteCommand(type: .local(file: "skadnetworkcommand"), delegate: self)
        self.conversion = skadCommand.conversionData
        config.remoteCommands = [
            skadCommand
        ]

        tealium = Tealium(config: config) { [weak self] response in
            guard let self = self,
                  let teal = self.tealium else {
                return

            }
        }
    }

    func track(title: String, data: [String: Any]?) {
        let dispatch = TealiumEvent(title, dataLayer: data)
        tealium?.track(dispatch)
    }

    func trackView(title: String, data: [String: Any]?) {
        let dispatch = TealiumView(title, dataLayer: data)
        tealium?.track(dispatch)
    }
}

extension TealiumHelper: DispatchListener {
    public func willTrack(request: TealiumRequest) {
        if let request = request as? TealiumTrackRequest {
            _onWillTrack.publish(request.trackDictionary)
        }
        if self.enableHelperLogs {
            print("helper - willtrack")
        }
    }
}
