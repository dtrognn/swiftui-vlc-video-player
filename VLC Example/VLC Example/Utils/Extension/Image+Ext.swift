//
//  Image+Ext.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

extension Image {
    func applyTheme(_ color: Color = AppStyle.theme.iconColor) -> some View {
        self.renderingMode(.template)
            .foregroundColor(color)
    }
}
