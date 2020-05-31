import UIKit
import AVKit

let screenWidth: CGFloat = UIScreen.main.bounds.size.width
let screenHeight: CGFloat = UIScreen.main.bounds.size.height

let buttonWidth: CGFloat = 80.0
let buttonHeight: CGFloat = 30.0
let buttonPad: CGFloat = 10.0

let N_imgDefault: Int = 4

let slideImageWidth: CGFloat = 15.0
let slideLineHeight: CGFloat = 4.0
let leftTag: Int = 1
let rightTag: Int = 2
let shadowAlpha: CGFloat = 0.6

let indicatorRadius: CGFloat = 5.0
let indicatorLineWidth: CGFloat = 1.0

let K_indicatorViewHeight: CGFloat = 0.6
let K_indicatorViewMidX: CGFloat = K_scrollViewX + K_scrollViewWidth * 0.5
let K_indicatorViewY: CGFloat = 0.2

let K_videoScrollViewY: CGFloat = 0.25
let K_videoScrollViewHeight: CGFloat = 0.25
let K_scrollViewX: CGFloat = 0.2
let K_scrollViewWidth: CGFloat = 0.75
let K_scrollViewHeight: CGFloat = 0.8
let K_scrollViewOffset: CGFloat = K_indicatorViewMidX - K_scrollViewX
let scrollViewX: CGFloat = screenWidth * K_scrollViewX
let scrollViewWidth: CGFloat = screenWidth * K_scrollViewWidth
let scrollViewContentWidth: CGFloat = scrollViewWidth * 1.0
let scrollViewStandardOffset: CGFloat = -screenWidth * K_scrollViewOffset

let timeTolerance: CMTime = CMTime.zero
