//
//  CommentTile.swift
//  Star21Mobile
//
//  Created by Jason Tse on 20/11/2023.
//

import SwiftUI

extension TicketView {
    struct CommentTile: View {
        let comment: CommentEntity

        var body: some View {
            HStack {
                Text(comment.body)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(comment.author)
                    Text(comment.createdAt.formatted())
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
        }
    }
}

struct CommentTile_Previews: PreviewProvider {
    static var previews: some View {
        TicketView.CommentTile(comment: MockData.comment)
    }
}
