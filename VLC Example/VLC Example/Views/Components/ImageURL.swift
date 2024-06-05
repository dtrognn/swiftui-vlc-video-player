//
//  ImageURL.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI

struct ImageURL: View {
    let urlString: String

    private var screenWidth = UIScreen.main.bounds.size.width - 4 * AppStyle.layout.standardSpace

    init(urlString: String) {
        self.urlString = urlString
    }

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }.frame(minHeight: 150, maxHeight: 200)
            .frame(width: screenWidth, height: screenWidth / 1.78)
    }
}

private extension ImageURL {
    var emptyView: some View {
        return HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }

    var failureView: some View {
        return HStack {
            Spacer()
            imageFailure
            Spacer()
        }
    }

    var imageFailure: some View {
        return Image(systemName: "photo")
            .resizable()
            .frame(width: 50, height: 50)
    }
}

#Preview {
    ImageURL(urlString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKtKkuCjVMZ09HHU7OxCs0h7421BzTwVWGjA&s")
}
