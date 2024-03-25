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

    @State var stage: AnimatedSplashStage = .zero

    var body: some View {
        main
            .overlay {
                GeometryReader { geometry in
                    Image("launch_centre")
                        .resizable()
//                        .aspectRatio(contentMode: .fill)
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(stage == .zero ? 1 : stage == .third ? 50 : 2.6)
                        .animation(.easeInOut(duration: 1))
                        .opacity(stage == .third ? 0 : 1)
                        .animation(.easeIn(duration: 0.3))
                    }
                    .ignoresSafeArea()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        stage = .first
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        stage = .second
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        stage = .third
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

enum AnimatedSplashStage {
    case zero
    case first
    case second
    case third
}

struct AnimatedSplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedSplashScreen(EmptyView())
    }
}
