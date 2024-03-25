//
//  AppConfig.swift
//  Star21Mobile
//
//  Created by Jason Tse on 12/12/2023.
//

import Foundation

protocol AppConfig {
    var zendeskApiBaseUrl: String { get }
    var displayFormId: Int { get }
    var submitRequestFormId: Int { get }
    var networkLogging: Bool { get }
    var mobileDisplayFormOnly: Bool { get }
    var inPagingUX: Bool { get }
}

struct DevAppConfig: AppConfig {
    let zendeskApiBaseUrl = "https://star21cloud1679352336.zendesk.com/api/v2/"
    let displayFormId = 8439559802255
    let submitRequestFormId = 6619331468815
    let networkLogging = false
    let mobileDisplayFormOnly = true
    let inPagingUX = true
}

struct ProdAppConfig: AppConfig {
    let zendeskApiBaseUrl = "https://star21cloud.zendesk.com/api/v2/"
    let displayFormId = 0
    let submitRequestFormId = 0
    let networkLogging = false
    let mobileDisplayFormOnly = true
    let inPagingUX = true
}
