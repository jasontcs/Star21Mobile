//
//  Constant.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import Foundation

struct Constant {

    static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
