//
//  TextEditorOptional.swift
//  Star21Mobile
//
//  Created by Jason Tse on 26/2/2024.
//

import SwiftUI

struct TextEditorOptional: View {

    @Binding var text: String?

    init(text: Binding<String?>) {
        self._text = text
    }

    var body: some View {
        TextEditor(text: Binding(get: {
            text ?? ""
        }, set: { value in
            if value.isEmpty {
                text = nil
                return
            }
            text = value
        }))
    }
}

struct TextFieldOptional_Previews: PreviewProvider {
    static var previews: some View {
        TextEditorOptional(text: .constant(nil))
    }
}
