//
//  ReviewView.swift
//  MaxMovies
//
//  Created by Max zam on 09/03/2024.
//

import SwiftUI

struct ReviewsView: View {
    let reviews: [ReviewsResponse.Review]
    
    var body: some View {
        if !reviews.isEmpty {
            VStack(alignment: .leading) {
                NavigationLink {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {  // Use HStack for horizontal layout
                            ForEach(reviews) { review in
                                ReviewCard(review: review, showAllReviews: true)  // Extracted Review Card
                            }
                        }
                        .padding(.horizontal)
                    }
                } label: {
                    HStack(alignment: .lastTextBaseline) {
                        Text("Reviews")
                            .foregroundStyle(.primary)
                            .padding(.top)
                            .bold()
                            .accessibilityLabel("Reviews section.")
                        Spacer()
                        Text("See All")
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 20) {  // Use HStack for horizontal layout
                        ForEach(reviews, id: \.content) { review in
                            ReviewCard(review: review, showAllReviews: false)  // Extracted Review Card
                        }
                    }
                }
            }
        } else {
            Text("Reviews")
                .foregroundStyle(.primary)
                .padding(.top)
                .bold()
                .accessibilityLabel("Reviews section.")
            Text("No reviews available")
        }
    }
}

struct ReviewCard: View {
    let review: ReviewsResponse.Review
    let showAllReviews: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
            
            VStack(alignment: .leading) {
                
                if let rating = review.authorDetails.rating {
                    HStack {
                        Text(review.author)
                        Spacer()
                        Text("⭐️ \(String(format: "%.1f", rating))")
                    }
                    .padding(.bottom)
                }
                if showAllReviews {
                    ShowMoreTextView(review.content)
                } else {
                    NavigationLink {
                        ScrollView {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.ultraThickMaterial)
                                VStack {
                                    HStack {
                                        Text(review.author)
                                        if let rating = review.authorDetails.rating {
                                            Spacer()
                                            Text("⭐️ \(String(format: "%.1f", rating))")
                                        }
                                    }
                                    Text(review.content)
                                        .padding(.vertical)
                                }
                                .padding()
                            }
                        }
                        .padding()
                        .scrollIndicators(.hidden)
                    } label: {
                        Text(review.content)
                            .lineLimit(5)
                            .multilineTextAlignment(.leading)
                    }
                    .foregroundStyle(.primary)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: showAllReviews ? .infinity : 300)  // Set a fixed width for each card
    }
}

#Preview {
    ReviewsView(reviews: [ReviewsResponse.Review(author: "", authorDetails: ReviewsResponse.Review.AuthorDetails(rating: 11), content: "")])
}
