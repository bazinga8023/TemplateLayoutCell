//
//  KeyedHeightCache.swift
//  TemplateLayoutCell
//
//  Created by 张俊安 on 2018/3/12.
//  Copyright © 2018年 John.Zhang. All rights reserved.
//

import UIKit


protocol KeyedHeightCacheAccess {
    func existsHeight(for key: String) -> Bool
    func cache(_ height: Float, for key: String)
    func height(for key: String) -> Float
}



class KeyedHeightCache {

    private var mutableHeightsByKeyForPortrait = [String : Float]()
    private var mutableHeightsByKeyForLandscape = [String : Float]()

    private var mutableHeightsByKeyForCurrentOrientation: [String : Float] {
        get {
            return UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? mutableHeightsByKeyForPortrait : mutableHeightsByKeyForLandscape
        }
        set {
            UIDeviceOrientationIsPortrait(UIDevice.current.orientation) ? (mutableHeightsByKeyForPortrait = newValue) : (mutableHeightsByKeyForLandscape = newValue)
        }
    }

}

// MARK: - KeyedHeightCacheAccess
extension KeyedHeightCache: KeyedHeightCacheAccess {
    func existsHeight(for key: String) -> Bool {
        if let number = mutableHeightsByKeyForCurrentOrientation[key], number != -1 {
            return true
        }
        return false
    }

    func cache(_ height: Float, for key: String) {
        mutableHeightsByKeyForCurrentOrientation[key] = height

    }

    func height(for key: String) -> Float {
        return mutableHeightsByKeyForCurrentOrientation[key] ?? 0
    }

}







