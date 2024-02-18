//
//  InfoTile.swift
//  Star21Mobile
//
//  Created by Jason Tse on 22/11/2023.
//

import SwiftUI

struct InfoTile: View {

    let title: String
    let value: String?

    var body: some View {
        HStack {
            Text("\(title):")
            Spacer()
            Text(value ?? "-")
                .foregroundColor(.secondary)
        }
    }
}

struct InfoTile_Previews: PreviewProvider {
    static var previews: some View {
        InfoTile(title: "Name", value: "Mock User")
    }
}
