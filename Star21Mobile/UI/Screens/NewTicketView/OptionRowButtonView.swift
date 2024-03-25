//
//  OptionRowButtonView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 13/3/2024.
//

import SwiftUI

struct OptionRowButtonView: View {
    let title: String
    let onTap: () -> Void

    init(_ title: String, onTap: @escaping () -> Void) {
        self.title = title
        self.onTap = onTap
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    OptionRowButtonView("") {}
}
