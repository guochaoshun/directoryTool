//
//  main.swift
//  文件读取性能测试
//
//  Created by 郭朝顺 on 2024/1/20.
//

import Foundation

/// 文件大小转换
func readAbleFileSize(_ fileSize: CGFloat) -> String {

    // 系统选中文件夹,显示简介的值是按照除1000算的, 和系统保持一致吧
    let KB = 1000.0

    if fileSize < KB {
        return "\(fileSize) B"
    } else if fileSize < KB * KB {
        return String(format: "%.2f KB", (fileSize/KB))
    } else if fileSize < KB * KB * KB {
        return String(format: "%.2f MB", (fileSize/KB/KB))
    } else if fileSize < KB * KB * KB * KB {
        return String(format: "%.2f GB", (fileSize/KB/KB/KB))
    }
    fatalError("文件类型太大, 检查是否取错值")
}


let testDir = "/Users/uxin/Desktop/GitHub"


do {
    let start = Date().timeIntervalSince1970
    let fileSize = CHFileTool.showFileInfo(rootPath: testDir, sizeType: .byBiteSize)
    let end = Date().timeIntervalSince1970
    print("方案1:文件大小 ", readAbleFileSize(CGFloat(fileSize)))
    print("耗时: ", end-start)
}

do {
    let start = Date().timeIntervalSince1970
    let fileSize = CHFileTool.showFileInfo(rootPath: testDir, sizeType: .byAllocatedSize)
    let end = Date().timeIntervalSince1970
    print("方案2:文件大小 ", readAbleFileSize(CGFloat(fileSize)))
    print("耗时: ", end-start)
}

