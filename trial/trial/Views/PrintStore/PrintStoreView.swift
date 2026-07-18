//
//  PrintStoreView.swift
//  BlinkitFlow
//
//  Pixel-accurate rebuild from Figma node 1:244
//

import SwiftUI

@MainActor
public struct PrintStoreView: View {
    public init() {}

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // ── Shared Header ──
                printHeader

                // ── "Print Store" Title (Figma: x:103, y:214, w:167, h:39) ──
                // Centered, large, black bold text
                Text("Print Store")
                    .font(.system(size: 28, weight: .black))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)

                // ── Subtitle (Figma: x:40, y:253, w:296, h:17) ──
                Text("Blinkit ensures secure prints at every stage")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.horizontal, 40)

                // ── Documents Card (Figma: x:7, y:324, w:361, h:163) ──
                documentsCard
                    .padding(.top, 28)

                Spacer().frame(height: 60)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: – Shared Header
    private var printHeader: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Color(red: 0.1, green: 0.57, blue: 0.25)
                    .frame(height: 110)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Blinkit in")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.top, 52)
                        .padding(.leading, 16)

                    Text("16 minutes")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                        .padding(.top, 2)

                    HStack(spacing: 4) {
                        Text("HOME")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("- Sujal Dave, Ratanada, Jodhpur (Raj)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.leading, 16)
                    .padding(.top, 4)
                }

                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 36, height: 36)
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 55)
                }
            }
            .frame(height: 110)

            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray).font(.system(size: 15))
                Text("Search \"ice-cream\"")
                    .foregroundColor(Color(.placeholderText)).font(.system(size: 14))
                Spacer()
                Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 20)
                Image(systemName: "mic.fill")
                    .foregroundColor(.gray).font(.system(size: 15))
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.top, -4)
            .padding(.bottom, 12)
            .background(Color(red: 0.1, green: 0.57, blue: 0.25))
        }
    }

    // MARK: – Documents Card
    // Figma: x:7, y:324, w:361, h:163
    // Contains: "Documents" header, 3 bullet points with ✦, image on right, "Upload Files" button
    private var documentsCard: some View {
        ZStack(alignment: .topLeading) {
            // Card background — Figma: rounded rectangle, 361×163pt
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

            HStack(alignment: .top, spacing: 0) {
                // Left side — text content
                VStack(alignment: .leading, spacing: 0) {
                    // "Documents" — Figma x:20, y:340, w:79, h:17
                    Text("Documents")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.bottom, 14)

                    // Bullet 1 — Figma: ✦ x:16, y:364 + text x:38, y:364
                    bulletRow("Price starting at ₹3/page")
                    // Bullet 2 — Figma: ✦ x:16, y:381 + text x:38, y:381
                    bulletRow("Paper quality: 70 GSM")
                        .padding(.top, 6)
                    // Bullet 3 — Figma: ✦ x:15, y:398 + text x:38, y:398
                    bulletRow("Single side prints")
                        .padding(.top, 6)

                    // "Upload Files" button — Figma: x:20, y:435, w:125, h:40
                    Button(action: { BlinkitTheme.triggerHaptic(.medium) }) {
                        Text("Upload Files")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 125, height: 40)
                            .background(Color(red: 0.1, green: 0.57, blue: 0.25))
                            .cornerRadius(8)
                    }
                    .padding(.top, 16)
                }
                .padding(.leading, 16)
                .padding(.top, 16)

                Spacer()

                // Right side — image (Figma: x:255, y:367, w:90, h:90)
                Image("print_illustration")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.trailing, 16)
                    .padding(.top, 36) // align with bullets area
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 163)
        .padding(.horizontal, 7) // Figma: x:7 = 7pt margin
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            // ✦ bullet — Figma x:16
            Text("✦")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(Color(red: 0.1, green: 0.57, blue: 0.25))
                .frame(width: 14)

            // Text — Figma x:38
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    PrintStoreView()
}
