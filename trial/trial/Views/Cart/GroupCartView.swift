//
//  GroupCartView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct GroupCartView: View {
    @StateObject private var viewModel: GroupCartViewModel
    
    public init() {
        _viewModel = StateObject(wrappedValue: GroupCartViewModel())
    }
    
    public init(viewModel: GroupCartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Header Banner
                headerBanner
                
                // Active Participants Section
                participantsCard
                
                // Share Invite Link Card
                shareInviteCard
                
                // Group Items List tagged "Added by [Name]"
                groupItemsCard
                
                // DEMO Debug Action Button
                simulateTeammateButton
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle("Group Cart 👥")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerBanner: some View {
        VStack(spacing: 6) {
            HStack {
                Text("COLLABORATIVE ORDERING")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(BlinkitTheme.brandGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(BlinkitTheme.brandGreenLight)
                    .cornerRadius(6)
                Spacer()
            }
            
            Text("House Party Groceries 🥳")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Everyone can add items to this cart live in real-time.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var participantsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Active Room Members")
                .font(.system(size: 15, weight: .bold))
            
            HStack(spacing: 12) {
                ForEach(MockData.allUsers) { user in
                    HStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: user.colorHex))
                                .frame(width: 32, height: 32)
                            Image(systemName: user.avatarName)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        
                        Text(user.name)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    private var shareInviteCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Invite Friends")
                    .font(.system(size: 14, weight: .bold))
                Text("Code: \(viewModel.inviteCode)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Native ShareLink
            ShareLink(
                item: viewModel.inviteURL,
                subject: Text("Join my Blinkit Group Cart"),
                message: Text("Hey! Join my Blinkit group cart to add groceries together: \(viewModel.inviteURL)")
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12, weight: .bold))
                    Text("Share Invite")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(BlinkitTheme.brandGreen)
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
    
    private var groupItemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cart Items Breakdown")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 16)
            
            VStack(spacing: 10) {
                ForEach(viewModel.cartService.items) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: item.addedBy.colorHex).opacity(0.15))
                                .frame(width: 40, height: 40)
                            Image(systemName: item.product.systemImage)
                                .foregroundColor(Color(hex: item.addedBy.colorHex))
                                .font(.system(size: 18))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.product.name)
                                .font(.system(size: 14, weight: .semibold))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: item.addedBy.colorHex))
                                Text("Added by \(item.addedBy.name)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: item.addedBy.colorHex))
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("x\(item.quantity)")
                                .font(.system(size: 13, weight: .bold))
                            Text("₹\(Int(item.totalCost))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(BlinkitTheme.brandGreen)
                        }
                    }
                    .padding(12)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var simulateTeammateButton: some View {
        Button(action: {
            viewModel.simulateTeammateItemAdd()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "person.fill.badge.plus")
                    .font(.system(size: 16, weight: .bold))
                Text("Simulate Teammate Adding Item")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(BlinkitTheme.textPrimaryLight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(BlinkitTheme.yellow)
            .cornerRadius(14)
            .shadow(color: BlinkitTheme.yellow.opacity(0.4), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }
}
