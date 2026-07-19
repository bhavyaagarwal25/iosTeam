//
//  IncomingOrderCard.swift
//  RestaurantApp — Eternal Lite Demo
//
//  A full-bleed, print-quality order ticket card.
//  Designed to look like something a real POS terminal would print —
//  clean, high-contrast, immediately readable from across a table.
//

import SwiftUI

// MARK: - IncomingOrderCard

public struct IncomingOrderCard: View {

    public let order: ReceivedOrder

    // Entrance animation state
    @State private var appeared = false
    @State private var pulseRing = false

    private let zomatoRed   = Color(red: 0.90, green: 0.10, blue: 0.20)
    private let cardBG      = Color(red: 0.98, green: 0.98, blue: 0.97)
    private let dividerColor = Color(red: 0.88, green: 0.88, blue: 0.86)

    public var body: some View {
        VStack(spacing: 0) {
            ticketHeader
            Divider().background(dividerColor).padding(.horizontal, 20)
            itemsSection
            Divider().background(dividerColor).padding(.horizontal, 20)
            totalsSection
            footerSection
        }
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 16, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(order.isAcknowledged ? Color.green.opacity(0.5) : Color.orange.opacity(0.4), lineWidth: 1.5)
        )
        // Slide + fade entrance
        .offset(y: appeared ? 0 : 40)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }

    // ── HEADER ────────────────────────────────────────────────────────
    private var ticketHeader: some View {
        VStack(spacing: 0) {
            // Status banner
            HStack(spacing: 8) {
                if order.isAcknowledged {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("ACK SENT")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.green)
                } else {
                    // Pulsing dot — ack in flight
                    ZStack {
                        Circle()
                            .stroke(Color.orange.opacity(0.4), lineWidth: 2)
                            .frame(width: 16, height: 16)
                            .scaleEffect(pulseRing ? 1.6 : 1.0)
                            .opacity(pulseRing ? 0 : 1)
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                    }
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                            pulseRing = true
                        }
                    }
                    Text("SENDING ACK…")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.orange)
                }

                Spacer()

                // Mesh proof badge
                HStack(spacing: 4) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 10))
                    Text("via Bluetooth")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.08))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Restaurant name + order time
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.packet.restaurantName)
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.primary)
                    Text(timeString(order.receivedAt))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Order ID chip
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ORDER")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.secondary)
                    Text("#\(order.packet.id.uuidString.prefix(6).uppercased())")
                        .font(.system(size: 17, weight: .black, design: .monospaced))
                        .foregroundColor(zomatoRed)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Delivery address row
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(zomatoRed)
                Text(order.packet.deliveryAddress)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // COD + from-device row
            HStack(spacing: 12) {
                // COD badge
                HStack(spacing: 5) {
                    Image(systemName: "banknote")
                        .font(.system(size: 11))
                    Text("CASH ON DELIVERY")
                        .font(.system(size: 10, weight: .black))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(red: 0.1, green: 0.6, blue: 0.3))
                .clipShape(Capsule())

                // Sender device name
                HStack(spacing: 5) {
                    Image(systemName: "iphone")
                        .font(.system(size: 11))
                    Text(order.fromPeerName.replacingOccurrences(of: "'s iPhone", with: ""))
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.secondary.opacity(0.08))
                .clipShape(Capsule())

                // Hop count
                HStack(spacing: 5) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                    Text("\(order.packet.hopCount) hop\(order.packet.hopCount == 1 ? "" : "s")")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.secondary.opacity(0.08))
                .clipShape(Capsule())

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    // ── ITEMS ─────────────────────────────────────────────────────────
    private var itemsSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Text("ITEMS  (\(order.itemCount))")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.secondary)
                    .tracking(1)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 8)

            // Item rows
            ForEach(order.packet.items) { item in
                itemRow(item)
            }

            Spacer().frame(height: 14)
        }
    }

    private func itemRow(_ item: PacketOrderItem) -> some View {
        HStack(spacing: 12) {
            // Veg / Non-veg indicator (FSSAI standard)
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(item.isVeg ? Color.green : Color.red, lineWidth: 1.5)
                    .frame(width: 14, height: 14)
                Circle()
                    .fill(item.isVeg ? Color.green : Color.red)
                    .frame(width: 6, height: 6)
            }

            // Quantity badge
            Text("×\(item.quantity)")
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 28, height: 22)
                .background(Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 5))

            // Name
            Text(item.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()

            // Price
            Text("₹\(Int(item.price * Double(item.quantity)))")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color.clear)
    }

    // ── TOTALS ────────────────────────────────────────────────────────
    private var totalsSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Subtotal")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
                Text("₹\(Int(order.totalAmount))")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
            }

            Divider().background(Color.primary.opacity(0.15))

            HStack {
                Text("TOTAL (COD)")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.primary)
                Spacer()
                Text("₹\(Int(order.totalAmount))")
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundColor(zomatoRed)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // ── FOOTER ────────────────────────────────────────────────────────
    private var footerSection: some View {
        VStack(spacing: 8) {
            // Dashed separator (mimics a paper tear line)
            dashedLine

            HStack(spacing: 16) {
                // Prep time
                Label("~20 min prep", systemImage: "timer")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Divider().frame(height: 16)

                // Signature proof
                Label("Signed · Verified", systemImage: "lock.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                // Packet ID (mentor can compare with customer app)
                Text(order.packet.id.uuidString.prefix(8).uppercased())
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    private var dashedLine: some View {
        HStack(spacing: 4) {
            ForEach(0..<22, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.secondary.opacity(0.25))
                    .frame(width: 12, height: 1.5)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm:ss a"
        return f.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        IncomingOrderCard(order: ReceivedOrder(
            packet: OrderPacket(
                id: UUID(),
                timestamp: Date(),
                items: [
                    PacketOrderItem(id: "1", name: "Margherita Pizza", price: 299, quantity: 2, isVeg: true),
                    PacketOrderItem(id: "2", name: "Chicken Wings", price: 349, quantity: 1, isVeg: false),
                    PacketOrderItem(id: "3", name: "Coke 500ml", price: 60, quantity: 3, isVeg: true)
                ],
                restaurantId: "rst_001",
                restaurantName: "Pizza Paradise",
                deliveryAddress: "B-204, Sector 62, Noida",
                codFlag: true,
                hopCount: 1,
                originPublicKey: "dummyKey",
                originDeviceSignature: "dummySig"
            ),
            fromPeer: "Shubh's iPhone"
        ))
        .padding(20)
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
