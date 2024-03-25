//
//  UserInfoRepository.swift
//  Star21Mobile
//
//  Created by Jason Tse on 8/3/2024.
//

import Foundation
import CoreLocation
import Contacts
import UIKit

typealias Address = String

protocol UserInfoRepositoryProtocol {
    func getLocation() async -> (CLLocationCoordinate2D?, Address?)
    func getLocationPermssion() async -> CLAuthorizationStatus
    var ipAddress: String? { get }
    var deviceModel: String { get }
    var osVersion: String { get }
    var appVersion: String? { get }
}

class UserInfoRepository: NSObject, UserInfoRepositoryProtocol, CLLocationManagerDelegate {

    var manager: CLLocationManager?

    var locationContinuation: CheckedContinuation<(CLLocationCoordinate2D?, Address?), Never>?
    var locationPermissionContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        manager = CLLocationManager()
        manager?.delegate = self
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            locationPermissionContinuation?.resume(returning: manager.authorizationStatus)
            locationPermissionContinuation = nil
        case .restricted, .denied:  // Location services currently unavailable.
            locationPermissionContinuation?.resume(returning: manager.authorizationStatus)
            locationPermissionContinuation = nil
            break
        case .notDetermined:         // Authorization not determined yet.
//            manager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var address: String?

        guard let location = locations.first else {
            address = nil
            return
        }

        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil, let postalAddress = placemarks?.first?.postalAddress else {
                self.locationContinuation?.resume(returning: (nil, nil))
                self.locationContinuation = nil
                return
            }
            let formatter = CNPostalAddressFormatter()
            address = formatter.string(from: postalAddress)
            self.locationContinuation?.resume(returning: (location.coordinate, address))
            self.locationContinuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Error requesting location.")
        locationContinuation?.resume(returning: (nil, nil))
        locationContinuation = nil
    }

    func getLocationPermssion() async -> CLAuthorizationStatus {
        manager?.requestWhenInUseAuthorization()

        return await withCheckedContinuation { continuation in
            locationPermissionContinuation = continuation
        }
    }

    func getLocation() async -> (CLLocationCoordinate2D?, Address?) {
        _ = await self.getLocationPermssion()
        manager?.requestLocation()

        return await withCheckedContinuation { continuation in
            locationContinuation = continuation
        }
    }

    var ipAddress: String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
//            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            if addrFamily == UInt8(AF_INET) {

                // Check interface name:
                // wifi = ["en0"]
                // wired = ["en2", "en3", "en4"]
                // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

                let name = String(cString: interface.ifa_name)
                if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }

    var deviceModel: String {
        UIDevice.current.name
    }

    var osVersion: String {
        "iOS " + UIDevice.current.systemVersion
    }

    var appVersion: String? {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        if let version, let build {
            return "\(version)+\(build)"
        }
        return nil
    }
}
