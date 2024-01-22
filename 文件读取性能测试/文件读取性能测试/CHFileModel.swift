//
//  CHFileModel.swift
//  directoryInfo
//
//  Created by 郭朝顺 on 2024/1/20.
//

import Foundation

enum CHFileType: String {
    // 占位
    case none
    // 文件类型
    case file
    // 目录类型
    case directory
}

class CHFileModel: NSObject {

    // 文件路径
    var filePath: String = ""
    // 文件大小
    var fileSize: Int = 0
    // 文件类型
    var fileType: CHFileType = .none

    // 父节点
    var parentNode: CHFileModel?

    // 目录类型下 有子节点, 文件类型为空字典
    var subNode: [String: CHFileModel] = [:]

    @discardableResult
    func showOneLevelInfo() -> String {
        var result = self.description

        self.subNode.forEach { (key: String, value: CHFileModel) in
            result.append("\t" + value.description)
        }
        print(result)
        return result
    }


    override var description: String {
        get {
            return self.filePath + " 文件大小: \(readAbleFileSize(CGFloat(self.fileSize))) "  + "文件类型: \(self.fileType.rawValue)\n"
        }
    }


}
