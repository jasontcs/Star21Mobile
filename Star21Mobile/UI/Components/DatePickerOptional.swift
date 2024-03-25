//
//  DatePickerOptional.swift
//  Star21Mobile
//
//  Created by Jason Tse on 26/2/2024.
//

import SwiftUI

struct DatePickerOptional: View {

    let label: String
    let prompt: String
//    let range: PartialRangeThrough<Date>
    @Binding var date: Date?
    @State private var hidenDate: Date = Date()
    @State private var showDate: Bool = false

    init(_ label: String, prompt: String, selection: Binding<Date?>) {
        self.label = label
        self.prompt = prompt
        self._date = selection
    }

    var body: some View {
        ZStack {
            HStack {
                Text(label)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showDate {
                    Button {
                        showDate = false
                        date = nil
                    } label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .tint(.primary)
                    }
                    DatePicker(
                        label,
                        selection: $hidenDate,
//                        in: range,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .onChange(of: hidenDate) { newDate in
                        date = newDate
                    }

                } else {
                    Button {
                        showDate = true
                        date = hidenDate
                    } label: {
                        Text(prompt)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 120, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.3))
                    )
                    .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

struct DatePickerOptional_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerOptional("Date?", prompt: "Click", selection: .constant(Date()))
    }
}
