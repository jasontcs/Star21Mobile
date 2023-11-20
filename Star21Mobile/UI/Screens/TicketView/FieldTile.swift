//
//  FieldTile.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI

extension TicketView {
    struct FieldTile: View {

        let title: String
        let value: String?
        let isTag: Bool

        init(custom: CustomFieldValueEntity) {
            self.title = custom.field.title
            guard let value = custom.value else {
                self.value = nil
                self.isTag = false
                return
            }
            switch custom.field.type {
//            case .date:
//                <#code#>
//            case .assignee:
//                <#code#>
//            case .subject:
//                <#code#>
//            case .description:
//                <#code#>
//            case .status:
//                <#code#>
//            case .priority:
//                <#code#>
//            case .tickettype:
//                <#code#>
//            case .group:
//                <#code#>
//            case .customStatus:
//                <#code#>
//            case .text:
//                <#code#>
//            case .textarea:
//                <#code#>
//            case .checkbox:
//                <#code#>
//            case .integer:
//                <#code#>
//            case .decimal:
//                <#code#>
//            case .regexp:
//                <#code#>
//            case .partialcreditcard:
//                <#code#>
//            case .multiselect:
//                <#code#>
//            case .tagger:
//                <#code#>
//            case .lookup:
//                <#code#>
            default:
                self.isTag = false
                guard let value = custom.value?.raw() else {
                    self.value = nil
                    return
                }
                self.value = "\(value)"
            }
        }

        init(title: String, value: String?, isTag: Bool = false) {
            self.title = title
            self.value = value
            self.isTag = isTag
        }

        var body: some View {
            HStack {
                Text(title)
                Spacer()
                if isTag {
                    Text(value ?? "-").foregroundColor(.red)
                } else {
                    Text(value ?? "-").foregroundColor(.secondary)
                }
            }
        }
    }
}

struct FieldTile_Previews: PreviewProvider {
    static var previews: some View {
        TicketView.FieldTile(custom: MockData.custom)
    }
}
