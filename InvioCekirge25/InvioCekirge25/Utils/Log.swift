//
//  Log.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 26.03.2025.
//

import Foundation

enum Log {
    enum LogLevel {
        case success
        case info
        case warning
        case error
        
        fileprivate var prefix: String {
            switch self {
            case .success:
                return "🟢 SUCCESS"
            case .info:
                return "INFO"
            case .warning:
                return "🟡 WARNING"
            case .error:
                return "🔴 ERROR"
            }
        }
    }
    
    struct Context {
        let file: String
        let function: String
        let line: Int
        var description: String {
            return "\((file as NSString).lastPathComponent): \(line) \(function)"
        }
    }
    
    static func success(_ str: StaticString, shouldLongContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .success, str: str.description, shouldLogContext: shouldLongContext, context: context)
    }
    
    static func info(_ str: StaticString, shouldLongContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .info, str: str.description, shouldLogContext: shouldLongContext, context: context)
    }
    
    static func warning(_ str: StaticString, shouldLongContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .warning, str: str.description, shouldLogContext: shouldLongContext, context: context)
    }
    
    static func error(_ str: StaticString, shouldLongContext: Bool = true, file: String = #file, function: String = #function, line: Int = #line) {
        let context = Context(file: file, function: function, line: line)
        Log.handleLog(level: .error, str: str.description, shouldLogContext: shouldLongContext, context: context)
    }
    
    fileprivate static func handleLog(level: LogLevel, str: String, shouldLogContext: Bool, context: Context) {
        let logComponents = ["[\(level.prefix)]", str]
        
        var fullString = logComponents.joined(separator: " ")
        if shouldLogContext {
            fullString += " → \(context.description)"
        }
        
#if DEBUG
        print(fullString)
#endif
    }
}

