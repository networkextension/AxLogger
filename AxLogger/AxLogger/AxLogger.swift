//
//  Logger.swift
//  QoodMessageProcessor
//
//  Created by xiaop on 15/6/23.
//  Copyright (c) 2015年 xiaop. All rights reserved.
//

import Foundation
@objc public enum AxLoggerLevel:Int,CustomStringConvertible{
    // 调整优先级
    case Error = 0
    case Warning = 1
    case Info = 2
    case Notify = 3
    case Trace = 4
    case Verbose = 5
    case Debug = 6
    public var description: String {
        switch self {
        case .Error: return "Error"
        case .Warning: return "Warning"
        case .Info: return "Info"
        case .Notify: return "Notify"
            
        case .Trace: return "Trace"
        case .Verbose: return "Verbose"
        case .Debug: return "Debug"
        }
    }
}
func createLogDir(){
    
}
func reopenStdout(baseURL:URL){
    //    NSString *path=[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"log.txt"];
    //    char *p =(char*)[path UTF8String];
    //    freopen( p, "w", stdout);
    //    if !log_ENABLE_REOPEN {
    //        return
    //    }
    if let info = Bundle.main.infoDictionary, let appid =  info["CFBundleIdentifier"] as? String{
        if appid != "com.yarshure.Surf.PacketTunnel" {
            return
        }
        
    }
    createLogDir()
    let date = Date()
    let df = DateFormatter()
    df.dateFormat = "yyyy_MM_dd_HH_mm_ss"
    let string = df.string(from: date)
    let url = baseURL.appendingPathComponent("Log/\(string)_stdout.log")
    
    
    //let url1 = groupContainerURL.appendingPathComponent("Log/\(string).log")
    
    let path = url.path
        let x = path.cString(using: String.Encoding.utf8)
        //let p:UnsafePointer<Int8> = UnsafePointer.in
        
        freopen(x!, "w", stderr)
        
        // let x2 = url1.path!.cStringUsingEncoding(NSUTF8StringEncoding)
        // freopen(x2!, "w", stderr)
        
        //NSLog("######################### reopen ok")
        
        
        
}


//public struct StderrStream: OutputStreamType {
//    static var shared = StderrStream()
//    public func write(string: String) {
//        fputs(string, stderr)
//    }
//}

/// SimpleTunnel errors
protocol AxLogFormater{
    func formate(msg:String,level:AxLoggerLevel,category:String,file:String,line:Int,ud:[String:String],tags:[String],time:Date) -> String
}
func memoryUsed() -> String {
    let mem =  reportMemoryUsed()
    return memoryString(memoryUsed: mem)

}
func memoryString(memoryUsed:UInt64) ->String {
    let f = Float(memoryUsed)
    if memoryUsed < 1024 {
        return "\(memoryUsed) Bytes"
    }else if memoryUsed >=  1024 &&  memoryUsed <  1024*1024 {
        
        return  String(format: "%.2f KB", f/1024.0)
    }
    return String(format: "%.2f MB", f/1024.0/1024.0)
    
}
class AxLogDefaultFormater:AxLogFormater{
   

    lazy var df:DateFormatter={
        var f:DateFormatter=DateFormatter()
        //f.dateFormat="yyyy/MM/dd HH:mm:ss.SSS" file name contain date
        f.dateFormat="HH:mm:ss.SSS"
        return f
    }()
    func formate(msg:String,level:AxLoggerLevel,category:String,file:String,line:Int,ud:[String:String],tags:[String],time:Date) -> String{
        let timestr = self.df.string(from: time)
        
        //let filename = file.NS.lastPathComponent
        let processinfo = ProcessInfo.processInfo
        
        let threadid = pthread_mach_thread_np(pthread_self())
        #if os(iOS)
            let memory = memoryString(memoryUsed: reportMemoryUsed())
            #else
            let memory = ""
            #endif
        var  result:String = ""
//        if level == .Debug {
//            
//            let fn = file.components(separatedBy: "/").last
//            result = "\(timestr) \(level.description) [\(processinfo.processIdentifier):\(threadid)] mem:\(memory) \(fn!)[\(line)] \(msg) " //\(category)
//        }else {
//            
//        }
        #if DEBUG
            result = "\(timestr) \(level.description) [\(processinfo.processIdentifier):\(threadid)] mem:\(memory) \(msg) " //\(category) \(filename)[\(line)]
        #else
            result = "\(timestr) \(level.description) mem:\(memory) \(msg)  "
        #endif
        
        return result
    }
}

public class AxLogger:NSObject{
    static var groupURL = URL.init(string: "http://abigt.net")!
    static var applog:AxLogFile = {
        var urlContain:URL?
        #if os(iOS)
             //let c  = FileManager.default.containerURLForSecurityApplicationGroupIdentifier("group.com.yarshure.Surf")
             urlContain = groupURL.appendingPathComponent("Log")
            
        #else
            
            //NSString *groupContainer = [@"~/../../../Group Containers/TEAM_ID.com.Company.AppName" stringByExpandingTildeInPath];
            let c = FileManager.default.containerURLForSecurityApplicationGroupIdentifier("745WQDK4L7.com.yarshure.Surf")
            urlContain = c!.appendingPathComponent("Library/Application Support/Log")
        #endif
        
        guard let x = urlContain else {
            return AxLogFile(name: "applog",ext:"log", dir:"")
        }
        
        let dir = urlContain!.path
        #if (arch(i386) || arch(x86_64))
            let header = ["os":"simulator"]
        #else
            let header = AxEnvHelper.infoDict()
        #endif
        NSLog("logdir %@", dir)
        var logger = AxLogFile(name: "applog",ext:"log", dir:dir)
        //logger.enableConsole(true)
        return logger
    }()
    //let client = asl_open(nil, "com.apple.console", 0)
    static func closeLogging(){
        //log("\(applog) close logging file")
        applog.closeLog()
    }
    static func resetLogFile(){
        //applog.log("resetLogFile 000")
        applog.closeLog()
        applog.reopen()
        //applog.log("resetLogFile 111")
    }
    static func openLogging(baseURL:URL, date:Date){
        #if DEBUG
            reopenStdout(baseURL: baseURL)
        #endif
        let u  = groupURL.appendingPathComponent("Log")
        applog.openLogging(date: date ,path:u.path)
    }
    static var logleve:AxLoggerLevel = .Info
    
    static var logFormater = AxLogDefaultFormater()//= .Debug
    @objc static public func log(_ msg:String,level:AxLoggerLevel , category:String="default",file:String=#file,line:Int=#line,ud:[String:String]=[:],tags:[String]=[],time:Date=Date()){
        
        //other level
        
        #if DEBUG
            applog.log(msg: self.logFormater.formate(msg: msg, level: level, category: category, file: file, line: line, ud: ud, tags: tags, time: time))
        #else
            if level.rawValue <= self.logleve.rawValue {
                applog.log(msg: self.logFormater.formate(msg: msg, level: level, category: category, file: file, line: line, ud: ud, tags: tags, time: time))
            }
        #endif
    }
    
    @objc static public func enableConsole(enable:Bool){
        //applog.enableConsole(enable)
    }

}

typealias Qlog = AxLogger

