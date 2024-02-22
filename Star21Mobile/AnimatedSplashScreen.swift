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

    @State var animate = false
    @State var showSplash = true

    var body: some View {
        main
        .overlay {
            Image("launch")
                .resizable()
                .ignoresSafeArea()
//                .aspectRatio(contentMode: .fill)
                .scaledToFill()
                .scaleEffect(animate ? 50 : 1)
                .animation(.easeIn(duration: 0.5))
                .opacity(showSplash ? 1 : 0)
                .animation(.easeIn(duration: 0.3))

        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                animate.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showSplash.toggle()
            }
        }
//        if !finished {
//            LottieView(name: "splash") {
//                finished = true
//            }
//            .background(
//                Image("launch")
//                    .resizable()
//                    .scaledToFill()
//            )
//            .edgesIgnoringSafeArea(.all)
//        } else {
//            main
//        }
    }
}

struct AnimatedSplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedSplashScreen(EmptyView())
    }
}
