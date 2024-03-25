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

        init(comment: CommentEntity) {
            self.comment = comment
        }

        var body: some View {
            VStack {
                HStack {
                    Text(comment.body.markdownToAttributed() ?? "-")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(comment.author)
                        Text(comment.createdAt.formatted())
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
                HStack(spacing: 8) {
                    ForEach(comment.attachments) { attachment in
                        AsyncImage(
                            url: URL(string: attachment.url)!,
                            content: { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 84, height: 84)
                                    .clipped()
                            },
                            placeholder: {
                                ProgressView()
                                    .frame(width: 84, height: 84)
                            }
                        )
                    }
                    Spacer()
                }
            }
        }
    }
}

struct CommentTile_Previews: PreviewProvider {
    static var previews: some View {
        TicketView.CommentTile(comment: MockData.comment)
    }
}
