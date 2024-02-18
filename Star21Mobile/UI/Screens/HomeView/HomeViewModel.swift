//
//  HomeViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 20/12/2023.
//

import SwiftUI
import Combine
import Factory

extension HomeView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var searchText = ""

    }
}
