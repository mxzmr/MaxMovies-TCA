//
//  ShowMoreTextView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI

struct ShowMoreTextView: View {
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false
    private var content: String
    
    let lineLimit: Int
    
    init(_ text: String, lineLimit: Int = 4) {
        self.content = text
        self.lineLimit = lineLimit
    }
    
    private var moreLessText: String {
        if !truncated {
            return ""
        } else {
            return self.expanded ? "read less" : " read more"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(content)
                .lineLimit(expanded ? nil : lineLimit)
                .background(
                    Text(content).lineLimit(lineLimit)
                        .background(GeometryReader { visibleTextGeometry in
                            ZStack { //large size zstack to contain any size of text
                                Text(self.content)
                                    .background(GeometryReader { fullTextGeometry in
                                        Color.clear.onAppear {
                                            self.truncated = fullTextGeometry.size.height > visibleTextGeometry.size.height
                                        }
                                    })
                            }
                            .frame(height: .greatestFiniteMagnitude)
                        })
                        .hidden() //keep hidden
                )
            if truncated {
                Button(action: {
                    expanded.toggle()
                }, label: {
                    Text(moreLessText)
                })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            expanded.toggle()
        }
    }
}


#Preview {
    ShowMoreTextView("something about something")
}
