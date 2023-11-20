//
//  Stream.swift
//  Star21Mobile
//
//  Created by Jason Tse on 14/11/2023.
//

import Foundation
import Combine

extension Publisher {
    func listen(in set: inout Set<AnyCancellable>, receiveValue: @escaping ((Self.Output) -> Void)) {
        self.receive(on: DispatchQueue.main)
            .sink {_ in
            } receiveValue: { value in
                receiveValue(value)
            }
            .store(in: &set)
    }
}
