//
//  NotificationTile.swift
//  Star21Mobile
//
//  Created by Jason Tse on 27/12/2023.
//

import SwiftUI

struct NotificationTile: View {

    let notification: NotificationEntity

    var body: some View {
        HStack {
            Avatar(icon: "person.crop.circle.fill", radius: 24, circleColor: .gray, imageColor: .white)
            VStack(alignment: .leading) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                    Spacer()
                    Text(notification.createdAt.timeAgoDisplay())
                        .font(.caption2)
                }
                Text(notification.description)
                    .font(.caption)
            }
        }
    }
}

struct NotificationTile_Previews: PreviewProvider {
    static var previews: some View {
        NotificationTile(notification:
            .init(id: 1, title: "New Ticket", description: "new reply content, new reply content", content: "new reply content, new reply content", avatarUrl: nil, redirectUrl: nil, createdAt: Date(), updatedAt: Date(), status: .unread)
        )
    }
}
