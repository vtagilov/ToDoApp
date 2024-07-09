//
//  LoggerSetup.swift
//  ToDoApp
//
//  Created by Владимир on 08.07.2024.
//

import Foundation
import CocoaLumberjackSwift

final class LoggerSetup {
    static let shared = LoggerSetup()

    private init() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }

    func logError(_ message: String) {
        let logMessage = DDLogMessageFormat(stringLiteral: message)
        DDLogError(logMessage)
    }

    func logWarning(_ message: String) {
        let logMessage = DDLogMessageFormat(stringLiteral: message)
        DDLogWarn(logMessage)
    }

    func logInfo(_ message: String) {
        let logMessage = DDLogMessageFormat(stringLiteral: message)
        DDLogInfo(logMessage)
    }

    func getLogFilePaths() -> [String] {
        if let fileLogger = DDLog.allLoggers.first(where: { $0 is DDFileLogger }) as? DDFileLogger {
            return fileLogger.logFileManager.sortedLogFilePaths
        }
        return []
    }
}

