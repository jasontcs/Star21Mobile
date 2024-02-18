//
//  Counter.swift
//  Star21Mobile
//
//  Created by Jason Tse on 20/12/2023.
//

import SwiftUI

struct CounterArg: Hashable, Identifiable {
    let id = UUID()
    let iconName: String
    let count: Int
    let title: String
    let color: Color
}

struct Counter: View {
    let arg: CounterArg
    init(_ arg: CounterArg) {
        self.arg = arg
    }

    var body: some View {
        Button {

        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: arg.iconName)
                        .resizable()
                        .frame(width: 24, height: 24)
                    Spacer()
                    Text(String(arg.count))
                        .font(.title)
                }
                Text(arg.title)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.borderedProminent)
        .keyboardShortcut(.defaultAction)
        .tint(arg.color)
    }
}

struct Counter_Previews: PreviewProvider {
    static var previews: some View {
        Counter(.init(
            iconName: "pencil",
            count: 5,
            title: "On-going",
            color: .gray
        ))
    }
}
