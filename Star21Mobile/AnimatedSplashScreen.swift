//
//  AnimatedSplashScreen.swift
//  Star21Mobile
//
//  Created by Jason Tse on 18/12/2023.
//

import SwiftUI

struct AnimatedSplashScreen: View {
    let main: AnyView

    init(_ main: any View) {
        self.main = AnyView(main)
    }

    @State var finished = false

    var body: some View {
        if !finished {
            LottieView(name: "splash") {
                finished = true
            }
            .background(
                Image("splash")
            )
            .edgesIgnoringSafeArea(.all)
        } else {
            main
        }
    }
}

struct AnimatedSplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedSplashScreen(EmptyView())
    }
}
