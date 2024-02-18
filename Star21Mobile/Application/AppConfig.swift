//
//  AppConfig.swift
//  Star21Mobile
//
//  Created by Jason Tse on 12/12/2023.
//

import Foundation

protocol AppConfig {
    var zendeskApiBaseUrl: String { get }
    var simCardActivationFormId: Int { get }
    var mobileServiceRequestFormId: Int { get }
}

struct DevAppConfig: AppConfig {
    let zendeskApiBaseUrl = "https://star21cloud1679352336.zendesk.com/api/v2/"
    let simCardActivationFormId = 8439559802255
    let mobileServiceRequestFormId = 6619333591183
}

struct ProdAppConfig: AppConfig {
    let zendeskApiBaseUrl = "https://star21cloud.zendesk.com/api/v2/"
    let simCardActivationFormId = 0
    let mobileServiceRequestFormId = 0

}
