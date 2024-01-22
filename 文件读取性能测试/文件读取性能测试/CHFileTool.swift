//
//  CHFileTool.swift
//  directoryInfo
//
//  Created by 郭朝顺 on 2024/1/20.
//

import Foundation

enum CHFileToolSizeType {
    /// 使用磁盘大小计算
    case byAllocatedSize
    /// 使用字节大小计算
    case byBiteSize
}

class CHFileTool: NSObject {

    @discardableResult
    static func showFileInfo(rootPath: String, sizeType: CHFileToolSizeType = .byAllocatedSize) -> Int {

        // 1.一次IO操作,获取所有文件信息
        var fileModelArray: [CHFileModel] = []
        if sizeType == .byBiteSize {
            // 使用字节大小计算
            fileModelArray = self.getOriginFileInfo(rootPath: rootPath)
        } else if sizeType == .byAllocatedSize {
            // 使用磁盘占用计算
            fileModelArray = self.getOriginFileInfoByTotleSize(rootPath: rootPath)
        }

        // 2.构建文件树结构, 计算文件夹大小
        let rootModel = self.buildRootNode(rootPath: rootPath, originFileArray: fileModelArray)

        // 3.输出文件夹信息
        let dirArray = self.printAnalyzeInfo(rootModel: rootModel)

        // 随机挑部分数据测试
//        self.testRandomCase(dirArray: dirArray)

        return rootModel.fileSize

    }

    // 使用原始数据构造 文件树结构
    private static func buildRootNode(rootPath: String, originFileArray: [CHFileModel]) -> CHFileModel {
        let rootName = (rootPath as NSString).lastPathComponent

        let rootModel = CHFileModel()
        rootModel.fileSize = 0
        rootModel.filePath = rootName
        rootModel.fileType = .directory

        originFileArray.forEach { model in
            let pathComponents = (model.filePath as NSString).pathComponents
            self.buildTree(parenetNode: rootModel, currentNode: model, pathComponents: pathComponents)
        }

        rootModel.subNode.forEach { (key: String, value: CHFileModel) in
            rootModel.fileSize += value.fileSize
        }

        return rootModel

    }

    // 进行数据统计
    @discardableResult
    private static func printAnalyzeInfo(rootModel: CHFileModel) -> [CHFileModel] {


        //        print("统计信息 -- start")
        //        rootModel.showOneLevelInfo()

        var dirArray = [CHFileModel]()
        self.getAllDirectory(rootNode: rootModel, dirArray: &dirArray)

        //        print("按照文件名排序")
        dirArray.sort { pre, next in
            pre.filePath < next.filePath
        }
        //        print(dirArray)


        //        print("按照文件大小排序")
        dirArray.sort { pre, next in
            pre.fileSize > next.fileSize
        }
        //        print(dirArray)

        //        print("统计信息 -- end")

        return dirArray
    }

    private static func testRandomCase(dirArray: [CHFileModel]) {
        let index = (0..<dirArray.count).randomElement()!
        var randomNode = dirArray[index]
        print(randomNode)
        while let parentNode = randomNode.parentNode {
            print(parentNode)
            randomNode = parentNode
        }
    }

}

// 一次IO操作,获取所有文件信息,记录到数组中, 方法1,2差别不大, 方法2更贴近真实占用
extension CHFileTool {

    // 方法1: 通过文件的占用的字节数获取
    private static func getOriginFileInfo(rootPath: String) -> [CHFileModel] {

        let fileManager = FileManager.default

        let fileArray = try? fileManager.subpathsOfDirectory(atPath: rootPath)

        var fileModelArray = [CHFileModel]()
        fileArray?.forEach { file in
            let fullPath = rootPath + "/" + file
            let att = try? fileManager.attributesOfItem(atPath: fullPath)
            if let att {

                let fileSize = att[FileAttributeKey.size] as? Int ?? 0
                let fileType = att[FileAttributeKey.type] as? FileAttributeType
                let fileModel = CHFileModel()
                fileModel.fileSize = fileSize
                fileModel.filePath = file
                if let fileType {
                    if fileType == .typeRegular {
                        fileModel.fileType = .file
                    } else if fileType == .typeDirectory {
                        fileModel.fileType = .directory
                    } else {
//                        fatalError("不支持的文件类型 \(fileType)")
                    }
                } else {
                    fatalError("文件类型获取失败, \(att)")
                }
                fileModelArray.append(fileModel)
            } else {
                fatalError("文件信息获取失败, \(fullPath)")
            }
        }

//        print(fileModelArray)
        return fileModelArray
    }

    // 方法2: 通过磁盘上分配的空间来获取文件占用大小.
    // 一般来说, 文件在磁盘上的空间略大于文件的字节数, 因为存在磁盘对齐
    // 特殊的某些文件存在系统压缩, 会出现磁盘空间小于文件字节数的情况
    // 但是无论哪种, 磁盘上的空间更真实, 并且性能更好
    private static func getOriginFileInfoByTotleSize(rootPath: String) -> [CHFileModel] {

        let fileManager = FileManager.default


        let keysArray: [URLResourceKey] = [
            .isDirectoryKey,
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
        ]

        let keysSet = Set(keysArray)

        let directoryURL = URL(filePath: rootPath)
        let enumerator = fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: keysArray)!
        var fileModelArray = [CHFileModel]()

        // Perform the traversal.
        for item in enumerator {

            // Add up individual file sizes.
            if let contentItemURL = item as? URL {
                if let resourceValues = try? contentItemURL.resourceValues(forKeys: keysSet) {

                    let fileModel = CHFileModel()
                    fileModel.filePath =  contentItemURL.relativePath.replacingOccurrences(of: "\(rootPath)/", with: "")
                    if let isDirectory = resourceValues.isDirectory, isDirectory {
                        fileModel.fileType = .directory
                    } else if let isRegularFile = resourceValues.isRegularFile, isRegularFile {
                        fileModel.fileType = .file
                    } else {
//                        fatalError("不支持的类型\(resourceValues)")
                    }

                    // 文件在磁盘中的真实大小
                    if let fileSize = resourceValues.totalFileAllocatedSize {
                        fileModel.fileSize = fileSize
                    } else if let fileSize = resourceValues.fileAllocatedSize {
                        fileModel.fileSize = fileSize
                    } else {
//                        fatalError("文件大小无法获取")
                    }
                    fileModelArray.append(fileModel)
                }
            }
        }
//        print(fileModelArray)
        return fileModelArray
    }

}

// MARK: - 递归方法
extension CHFileTool {

    // 遍历获取根节点下所有文件夹信息
    private static func getAllDirectory(rootNode: CHFileModel, dirArray: inout [CHFileModel] ) {

        if rootNode.fileType == .directory {
            dirArray.append(rootNode)
        }
        rootNode.subNode.forEach { (key: String, value: CHFileModel) in
            self.getAllDirectory(rootNode: value, dirArray: &dirArray)
        }
    }


    // 构造树结构
    private static func buildTree(parenetNode: CHFileModel, currentNode: CHFileModel, pathComponents: [String]) {

        if pathComponents.isEmpty {
            return
        }

        var nextPathComponents = pathComponents
        let currentPath = nextPathComponents.removeFirst()

        // 查子路径
        // 子路径存在, 增加文件大小, 继续分解pathComponents
        // 子路径不存在, 创建子路径, 保存子路径, 分解pathComponents
        if let subNode = parenetNode.subNode[currentPath] {
            subNode.fileSize += currentNode.fileSize
            self.buildTree(parenetNode: subNode, currentNode: currentNode, pathComponents: nextPathComponents)

        } else {

            let subNode = CHFileModel()
            subNode.fileSize = currentNode.fileSize
            subNode.filePath = parenetNode.filePath + "/" + currentPath
            subNode.parentNode = parenetNode
            if pathComponents.count > 1 {
                subNode.fileType = .directory
            } else {
                subNode.fileType = currentNode.fileType
            }
            parenetNode.subNode[currentPath] = subNode
            self.buildTree(parenetNode: subNode, currentNode: currentNode, pathComponents: nextPathComponents)

        }

    }

}
