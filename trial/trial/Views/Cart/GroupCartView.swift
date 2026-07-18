//
//  GroupCartView.swift
//  BlinkitFlow
//

import SwiftUI

@MainActor
public struct GroupCartView: View {
    @StateObject private var viewModel: GroupCartViewModel
    @State private var showInviteSheet = false
    
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
                
                // Group Items List tagged "Added by [Name]"
                if !viewModel.cartService.items.isEmpty {
                    groupItemsCard
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle("Family Cart 👥")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showInviteSheet) {
            InviteFamilySheet(cartService: viewModel.cartService)
        }
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
            
            Text("Family Groceries 🏡")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Invite family members to add items to this cart live.")
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cart Members")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Button(action: {
                    showInviteSheet = true
                    BlinkitTheme.triggerHaptic(.medium)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Invite")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(BlinkitTheme.brandGreen)
                    .cornerRadius(8)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.cartService.invitedFamilyMembers) { user in
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: user.colorHex))
                                    .frame(width: 44, height: 44)
                                Image(systemName: user.avatarName)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            
                            Text(user.id == MockData.currentUser.id ? "You" : user.name)
                                .font(.system(size: 12, weight: .semibold))
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
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
                            Text(item.product.name.capitalized)
                                .font(.system(size: 14, weight: .semibold))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(hex: item.addedBy.colorHex))
                                Text("Added by \(item.addedBy.id == MockData.currentUser.id ? "You" : item.addedBy.name)")
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
}

struct InviteFamilySheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var cartService: CartService
    
    var availableContacts: [User] {
        MockData.allUsers.filter { user in
            user.id != MockData.currentUser.id &&
            !cartService.invitedFamilyMembers.contains(where: { $0.id == user.id })
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if availableContacts.isEmpty {
                    Text("All family members are already in the cart!")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(availableContacts) { user in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: user.colorHex))
                                    .frame(width: 40, height: 40)
                                Image(systemName: user.avatarName)
                                    .foregroundColor(.white)
                            }
                            
                            Text(user.name)
                                .font(.system(size: 15, weight: .medium))
                            
                            Spacer()
                            
                            Button("Invite") {
                                cartService.inviteFamilyMember(user)
                                BlinkitTheme.triggerNotificationHaptic(.success)
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(BlinkitTheme.brandGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(BlinkitTheme.brandGreenLight)
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Invite Family")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
