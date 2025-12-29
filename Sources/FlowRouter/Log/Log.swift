
//  Created by xiaoxiang's m1 mbp on 2024/3/26.
//
//
//  Log.swift
//

//import CocoaLumberjackSwift
//import CocoaLumberjackSwiftLogBackend
import UIKit
enum Log {

    // MARK: - 1. 日志级别

    enum Level: UInt {
        case verbose = 0
        case debug
        case info
        case warning
        case error
        var emoji: String {
            switch self {
            case .verbose: return "🔍"
            case .debug  : return "🐛"
            case .info   : return "ℹ️"
            case .warning: return "⚠️"
            case .error  : return "❌"
            }
        }
    }

    // MARK: - 2. 公共配置

    static let logLevel: Level = .verbose
    // MARK: - 3. 初始化（启动时只调一次）

    /// 在 App 启动时先调用，配置好各种 Logger
    static func setup() {
        // a. 控制台 / 系统日志
//        let osLogger = DDOSLogger.sharedInstance
//        DDLog.add(osLogger)
//
//        // b. 文件
//        DDLog.add(fileLogger)
//
//        // c. 自定义格式化
//        let fmt = SimpleFormatter()
//        osLogger.logFormatter = fmt
//        fileLogger.logFormatter = fmt

    }

    // MARK: - 4. 对外快捷方法

    static func v(_ tag: String, _ msg: String) {
        print("\(Level.verbose.emoji)[\(tag)] \(msg)")
    }

    static func d(_ tag: String, _ msg: String) {
        print("\(Level.debug.emoji)[\(tag)] \(msg)")
    }

    static func i(_ tag: String, _ msg: String) {
        print("\(Level.info.emoji)[\(tag)] \(msg)")
    }

    static func w(_ tag: String, _ msg: String) {
        print("\(Level.warning.emoji)[\(tag)] \(msg)")
    }

    static func e(_ tag: String, _ msg: String) {
        print("\(Level.error.emoji)[\(tag)] \(msg)")
    }

}

// MARK: - 可选：简单格式化器
//
//private final class SimpleFormatter: NSObject, DDLogFormatter {
//    private let df: DateFormatter = {
//        let f = DateFormatter()
//        f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
//        return f
//    }()
//
//    func format(message logMessage: DDLogMessage) -> String? {
//        let time = df.string(from: logMessage.timestamp)
//        return "\(time) \(logMessage.message)"
//    }
//}
