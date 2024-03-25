//
//  CustomBackButtonView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 1/3/2024.
//

import SwiftUI

struct CustomBackButtonView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let content: () -> Content
    let onBack: () -> Void
    let visible: Bool

    init(visible: Bool = true, @ViewBuilder content: @escaping () -> Content, onBack: @escaping () -> Void) {
        self.visible = visible
        self.content = content
        self.onBack = onBack
    }

    var body: some View {
        content()

        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: visible ? Button(action: {
            onBack()
//            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        } : nil)
    }
}

struct CustomBackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CustomBackButtonView {
            EmptyView()
        } onBack: {
            //
        }
    }
}
