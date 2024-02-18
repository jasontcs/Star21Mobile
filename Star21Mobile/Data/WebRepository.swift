//
//  WebRepository.swift
//  Star21Mobile
//
//  Created by Jason Tse on 6/11/2023.
//

import Foundation
import Factory
import OSLog

protocol WebRepository {
    var session: URLSession { get }
    var baseURL: String { get }

    var logging: Bool { get }
}

extension WebRepository {

    func call<Value>(endpoint: APICall) async throws -> Value
    where Value: Decodable {
        let request = try endpoint.urlRequest(baseURL: baseURL)

        do {
            if let body = request.httpBody {
                let dict = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
                log("[REQUEST] \(String(describing: dict?.debugDescription))")
            }
        } catch {
            logErr("\(error.localizedDescription)")
        }

        let (data, response) = try await session.data(for: request)
        let httpResponse = response as? HTTPURLResponse

        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            log("[RESPONSE] \(String(describing: dict?.debugDescription))")
        } catch {
            logErr("\(error.localizedDescription)")
        }

        guard let code = httpResponse?.statusCode else {
            throw APIError.unexpectedResponse
        }

        guard HTTPCodes.success.contains(code) else {
            throw APIError.httpCode(code)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Value.self, from: data)
    }

    private func log(_ message: String) {
        guard logging else { return }
        Logger().debug("\(message)")
    }
    private func logErr(_ message: String) {
        guard logging else { return }
        Logger().error("\(message)")
    }
}
