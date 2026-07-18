//
//  PrintStoreView.swift
//  BlinkitFlow
//
//  Premium iOS Native UI Rebuild
//

import SwiftUI

@MainActor
public struct PrintStoreView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                printHeader
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Text("Print Store")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                            .padding(.horizontal, 16)

                        Text("Blinkit ensures secure prints at every stage")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                            .padding(.horizontal, 32)

                        documentsCard
                            .padding(.top, 40)
                            .padding(.horizontal, 16)

                        Spacer().frame(height: 60)
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: – Shared Header
    private var printHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Blinkit in")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: 4) {
                        Text("16 minutes")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 4) {
                        Text("HOME")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Text("- Sujal Dave, Ratanada, Jodhpur (Raj)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Search Bar
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 18, weight: .medium))
                    Text("Search \"ice-cream\"")
                        .foregroundColor(Color.gray.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Divider()
                        .frame(height: 20)
                    Image(systemName: "mic.fill")
                        .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                        .font(.system(size: 18))
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding(.top, 10)
        .background(
            Color(red: 0.1, green: 0.57, blue: 0.25)
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: – Documents Card
    private var documentsCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Documents")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.bottom, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        bulletRow("Price starting at ₹3/page")
                        bulletRow("Paper quality: 70 GSM")
                        bulletRow("Single side prints")
                    }

                    Button(action: { BlinkitTheme.triggerHaptic(.medium) }) {
                        Text("Upload Files")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 140, height: 48)
                            .background(Color(red: 0.1, green: 0.57, blue: 0.25))
                            .cornerRadius(12)
                            .shadow(color: Color(red: 0.1, green: 0.57, blue: 0.25).opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 24)
                }
                .padding(.leading, 24)
                .padding(.top, 24)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "printer.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 24)
                .padding(.top, 40)
            }
            .padding(.bottom, 24)
        }
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary.opacity(0.9))
        }
    }
}
