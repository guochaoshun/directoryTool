//
//  MathTool.swift
//  directoryInfo
//
//  Created by 郭朝顺 on 2024/1/20.
//

import Foundation

// 左侧为CGFloat, 右侧为Int
public func * (left: CGFloat, right: Int) -> CGFloat {
    return left * CGFloat(right)
}


public func + (left: CGFloat, right: Int) -> CGFloat {
    return left + CGFloat(right)
}


public func - (left: CGFloat, right: Int) -> CGFloat {
    return left - CGFloat(right)
}


public func / (left: CGFloat, right: Int) -> CGFloat {
    if right == 0 {
        return CGFloat.nan
    } else {
        return left * CGFloat(right)
    }
}

// 左侧为Int, 右侧为CGFloat
public func * (left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) * right
}


public func + (left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) + right
}


public func - (left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) - right
}


public func / (left: Int, right: CGFloat) -> CGFloat {
    if right == 0 {
        return CGFloat.nan
    } else {
        return CGFloat(left) / right
    }
}
