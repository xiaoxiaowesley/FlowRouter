//
//  RouteCloseData.swift
//  FlowRouter
//
//  Created by xiaoxiang on 2025/12/29.
//

import Foundation

final public class RouteCloseData: @unchecked Sendable {
    public let value: [String: Any]?
    init(_ v: [String: Any]?) { value = v }
}

