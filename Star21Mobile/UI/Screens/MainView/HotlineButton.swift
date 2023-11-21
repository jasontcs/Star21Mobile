//
//  HotlineButton.swift
//  Star21Mobile
//
//  Created by Jason Tse on 21/11/2023.
//

import SwiftUI

struct HotlineButton: View {
    var body: some View {
        Link(destination: URL(string: "tel:+611300782721")!) {
            Image(systemName: "phone")
        }
    }
}

struct HotlineButton_Previews: PreviewProvider {
    static var previews: some View {
        HotlineButton()
    }
}
