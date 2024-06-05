//
//  VideoItemView.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

struct VideoItemView: View {
    private var video: Video
    private var onClick: (Video) -> Void

    let urlTemp = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKtKkuCjVMZ09HHU7OxCs0h7421BzTwVWGjA&s"

    init(video: Video, onClick: @escaping (Video) -> Void) {
        self.video = video
        self.onClick = onClick
    }

    var body: some View {
        Button {
            onClick(video)
        } label: {
            VStack(spacing: AppStyle.layout.zero) {
                VStack(spacing: AppStyle.layout.standardSpace) {
                    imageView
                    VStack(alignment: .leading, spacing: AppStyle.layout.mediumSpace) {
                        HStack(spacing: AppStyle.layout.smallSpace) {
                            title
                            Spacer()
                            subtitle
                        }
                        description
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.all, AppStyle.layout.standardSpace)
            }.background(AppStyle.theme.rowCommonBackgroundColor)
                .cornerRadius(AppStyle.layout.standardCornerRadius)
        }
    }
}

private extension VideoItemView {
    var imageView: some View {
        return ImageURL(urlString: video.thumbURL)
            .cornerRadius(AppStyle.layout.standardCornerRadius)
    }

    var title: some View {
        return Text(video.title)
            .font(AppStyle.font.regular16)
            .foregroundColor(AppStyle.theme.textNormalColor)
            .lineLimit(1)
    }

    var subtitle: some View {
        return Text(video.subtitle.rawValue)
            .font(AppStyle.font.regular14)
            .foregroundColor(AppStyle.theme.textNoteColor)
    }

    var description: some View {
        return Text(video.description)
            .font(AppStyle.font.regular14)
            .foregroundColor(AppStyle.theme.textNoteColor)
            .lineSpacing(AppStyle.layout.lineSpacing)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    VideoItemView(video: Video(
        description: "The first Blender Open Movie from 2006",
        sources: [],
        subtitle: .byBlenderFoundation,
        thumb: "images/ForBiggerFun.jpg",
        title: "Elephant Dream"),
    onClick: { _ in })
}
