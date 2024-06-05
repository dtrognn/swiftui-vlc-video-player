//
//  Theme.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

public protocol IAppTheme {
    var textNoteColor: Color { get }
    var textNormalColor: Color { get }
    var textUnderlineColor: Color { get }
    var textErrorMessageColor: Color { get }
    var textSelectedColor: Color { get }
    var textUnSelectedColor: Color { get }
    var textDeviceOnlineColor: Color { get }
    var textDeviceOfflineColor: Color { get }

    var btTextEnableColor: Color { get }
    var btTextDisableColor: Color { get }
    var btBackgroundEnableColor: Color { get }
    var btBackgroundDisableColor: Color { get }

    var naviTextColor: Color { get }
    var naviBackIconColor: Color { get }

    var tfBorderNormalColor: Color { get }
    var tfBorderActiveColor: Color { get }
    var tfFillNormalColor: Color { get }
    var tfFillDisableColor: Color { get }

    var shadowColor: Color { get }
    var lineColor: Color { get }
    var iconColor: Color { get }
    var iconNormalColor: Color { get }
    var iconHighlightColor: Color { get }

    var backgroundColor: Color { get }
    var rowCommonBackgroundColor: Color { get }
    var sectionBackgroundColor: Color { get }

    var tabbarViewColor: UIColor { get }

    var iconOnColor: Color { get }
    var iconOffColor: Color { get }

    var backgroundPopupColor: Color { get }

    var btnEnableColor: Color { get }
    var btnDisableColor: Color { get }
    var whiteTextColor: Color { get }
    var authenticationBackgroundColor: Color { get }
}

public struct AppTheme: IAppTheme {
    public var whiteTextColor: Color { return Color(hexString: "#FFFFFF")! }
    public var authenticationBackgroundColor: Color { return Color(hexString: "#836096")! }

    public var btnEnableColor: Color { return Color(hexString: "#C08261")! }
    public var btnDisableColor: Color { return Color(hexString: "#9E9FA5")! }

    public var textNoteColor: Color { return Color(hexString: "#3C3C43", opacity: 0.6)! } // "#262626")! }
    public var textNormalColor: Color { return Color(hexString: "#000000")! }
    public var textUnderlineColor: Color { return Color(hexString: "#007AFF")! } // Color { return Color.blue }

    public var textErrorMessageColor: Color { return Color(hexString: "#E60A32")! }
    public var textSelectedColor: Color { return Color(hexString: "#22313F")! }
    public var textUnSelectedColor: Color { return Color(hexString: "#011222", opacity: 0.4)! }
    public var textDeviceOnlineColor: Color { return Color(hexString: "#34c759")! }
    public var textDeviceOfflineColor: Color { return Color(hexString: "#F59000")! }

    public var btTextEnableColor: Color { return Color(hexString: "#FFFFFF")! }
    public var btTextDisableColor: Color { return Color(hexString: "#FFFFFF")! }
    public var btBackgroundEnableColor: Color { return Color(hexString: "#3F2305")! }
    public var btBackgroundDisableColor: Color { return Color(hexString: "#A0A1A8")! }

    public var naviBackIconColor: Color { return Color(hexString: "#22313F")! }
    public var naviTextColor: Color { return Color(hexString: "#22313F")! }

    public var tfBorderNormalColor: Color { return Color(hexString: "#011222", opacity: 0.1)! }
    public var tfBorderActiveColor: Color { return Color(hexString: "#2F6BFF", opacity: 0.8)! }
    public var tfFillNormalColor: Color { return Color(hexString: "#3F2305")! }
    public var tfFillDisableColor: Color { return Color(hexString: "#011222", opacity: 0.05)! }

    public var shadowColor: Color { return Color(hexString: "#000000")!.opacity(0.16) }
    public var lineColor: Color { return Color(hexString: "#E6E6E6")! }

    public var iconColor: Color { return Color(hexString: "#86401F")! }
    public var iconNormalColor: Color { return Color(hexString: "#22313F")! }
    public var iconHighlightColor: Color { return Color(hexString: "#86401F")! }
    public var backgroundColor: Color { return Color(hexString: "#F5EFE7")! }
    public var rowCommonBackgroundColor: Color { return Color(hexString: "#FFFFFF")! }
    public var sectionBackgroundColor: Color { return Color(hexString: "#011222", opacity: 0.1)! }

    public var tabbarViewColor: UIColor { return UIColor.white }

    public var iconOnColor: Color { return Color(hexString: "#86401F")! }
    public var iconOffColor: Color { return Color(hexString: "#011222", opacity: 0.5)! }

    public var backgroundPopupColor: Color { return Color.black.opacity(0.2) }
}
