//
//  LottieView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 18/12/2023.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode

    let completion: (() -> Void)?

    init(name: String = "loading", loopMode: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopMode
        self.completion = nil
    }
    init(name: String = "test", loopMode: LottieLoopMode = .playOnce, completion: @escaping ( () -> Void)) {
        self.name = name
        self.loopMode = loopMode
        self.completion = completion
    }

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play { finished in
            if finished {
                completion?()
            }
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView()
    }
}
