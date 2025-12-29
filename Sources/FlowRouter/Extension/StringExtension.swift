//
//  StringExtension.swift
//  GlobalIdleFish4iOS
//
//  Created by kingwu on 2024/7/6.
//

import Foundation

extension String {

    /// 将String解析出schema,host,path,query四部分
    ///
    /// - Returns: 解析出的schema,host,path,query四部分
    ///
    /// 例子：```
    /// let urlString = "callback://api/version?request=data"
    /// if let parsedURL = urlString.parseURL() {
    ///     print("Schema: \(parsedURL.schema ?? "N/A")")   // "callback"
    ///     print("Host: \(parsedURL.host ?? "N/A")")       //   "/api " (注意这里包含/ )
    ///     print("Path: \(parsedURL.path ?? "N/A")")       //  "version"
    ///     print("Query: \(parsedURL.query ?? "N/A")")     // "request=data"
    /// } else {
    ///     print("无法解析URL")
    /// }
    /// ```
    func parseURL() -> (schema: String?, host: String?, path: String?, query: String?)? {
        guard let urlComponents = NSURLComponents(string: self) else {
            Log.e("StringExtension", "无法解析URL:\(self)")
            return nil
        }

        let schema = urlComponents.scheme
        let host = urlComponents.host
        let path = urlComponents.path
        let query = urlComponents.query

        return (schema, host, path, query)
    }

    func urlStringNoParams() -> String {
        let schema = self.parseURL()?.schema
        let host = self.parseURL()?.host
        let path = self.parseURL()?.path
        return "\(schema ?? "")://\(host ?? "")\(path ?? "")"
    }

    /// 插入参数到String url中
    func appendUrlParams(params: [String: Any]) -> String {
        if params.isEmpty {
            return self
        }
        guard var urlComponents = URLComponents(string: self) else {
            return self
        }

        var queryItems = urlComponents.queryItems ?? []
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url?.absoluteString ?? self
    }

    func updateUrlParams(params: [String: Any]) -> String {
        guard var urlComponents = URLComponents(string: self) else {
            return self
        }

        // 获取现有的 queryItems
        var queryItems = urlComponents.queryItems ?? []

        // 更新或添加新的参数
        for (key, value) in params {
            if let index = queryItems.firstIndex(where: { $0.name == key }) {
                // 如果参数已存在，更新其值
                queryItems[index].value = "\(value)"
            } else {
                // 如果参数不存在，添加新的参数
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
        }

        // 设置更新后的 queryItems
        urlComponents.queryItems = queryItems

        return urlComponents.url?.absoluteString ?? self
    }

    /// 把 形如"key1=val1&key2=val2"转换成[String: String]类型
    /// - Returns: [String: String]结果

    func queryParameters() -> [String: String] {
        var query: [String: String] = [:]
        if self.contains("&") {
            let queryArray = self.components(separatedBy: "&")
            for queryItem in queryArray {
                let queryItemArray = queryItem.components(separatedBy: "=")
                if queryItemArray.count == 2 {
                    query[queryItemArray[0]] = queryItemArray[1]
                }
            }
        } else {
            let queryArray = self.components(separatedBy: "=")
            if queryArray.count == 2 {
                query[queryArray[0]] = queryArray[1]
            }
        }
        return query
    }

    func queryMap() -> [String: String] {

        guard let urlComponents = URLComponents(string: self) else {
            return [:]
        }

        // 获取现有的 queryItems
        let queryItems = urlComponents.queryItems ?? []

        // 将 queryItems 转换为 [String: String]
        var queryParameters: [String: String] = [:]
        for item in queryItems {
            queryParameters[item.name] = item.value
        }

        return queryParameters
    }

    /// 去除所有换行符
    func trim() -> String {
        return self.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
    }

    /// 将连续的换行符(\n / \r / \r\n)折叠成一个换行符
    func collapseNewlines() -> String {

        // 1. 去除文字最前面的所有换行符
        let trimmedStart = self.replacingOccurrences(
            of: "^(\\r\\n|\\n|\\r)+",
            with: "",
            options: .regularExpression
        )

        // 2 去除 1 次或多次连续出现的换行序列 (\r\n|\n|\r)+
        return trimmedStart.replacingOccurrences(
            of: "(\\r\\n|\\n|\\r)+",
            with: "\n",
            options: .regularExpression
        )
    }

    /// 把所有换行符换成空格
    func replaceNewlinesWithSpaces() -> String {
        return self.replacingOccurrences(of: "\n", with: " ")
    }


    /// 将 JSON 字符串转换为字典 [String: Any]
    func toJsonDictionary<Value>() -> Value? {
        // 将 JSON 字符串转换为 Data
        guard let jsonData = self.data(using: .utf8) else {
            Log.d("StringExtension", "Error: Could not convert string to data.")
            return nil
        }

        do {
            // 使用 JSONSerialization 解析 JSON 数据
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // 尝试将解析结果转换为 [String: Any]
            return jsonObject as? Value
        } catch {
            Log.d("StringExtension", "Error parsing JSON: \(error)")
            return nil
        }
    }

    /// 将一个可编码的对象转换为 JSON 字符串
    ///
    /// - Parameter object: 一个符合 Codable 协议的对象，这个对象将被编码为 JSON 格式。
    /// - Returns: 如果编码成功，返回对应的 JSON 字符串；如果编码失败，返回 nil。
    ///           在编码失败的情况下，将会在控制台打印错误信息。
    static func jsonString<T: Codable>(from object: T) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(object)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Failed to encode object: \(error)")
            return nil
        }
    }
}
