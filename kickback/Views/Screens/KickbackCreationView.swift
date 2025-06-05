import SwiftUI

struct KickbackCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var kickbackMgr: ActiveKickbackManager
    
    // View‑model that talks to KickbackService
    @StateObject private var vm = KickbackViewModel()
    
    
    // UI state
    @State private var showFriendPicker = false
    //    @State private var showCamera       = false
    //    @State private var capturedImages: [UIImage] = []

    // MARK: – Computed
    private var invitedCount: Int { vm.selectedFriends.count }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    /* Invite Friends */
                    Text("Invite Friends")
                        .font(.headline).padding(.top, 8)
                    
                    inviteeChips
                    
                    Button { showFriendPicker = true } label: {
                        HStack {
                            Text("+ Add More")
                                .foregroundColor(Color(hex: "#7B8C6A"))
                            Spacer()
                        }
                        .padding()
                        .background(Color(hex: "#E3E7DF"))
                        .cornerRadius(12)
                    }
                    
                    /* Kickback details */
                    Text("Kickback Details")
                        .font(.headline).padding(.top, 8)
                    
                    TextField("Kickback Name", text: $vm.title)
                        .padding().background(Color(hex: "#E3E7DF")).cornerRadius(12)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $vm.description)
                            .frame(height: 90)
                            .padding(8)
                            .background(Color(hex: "#E3E7DF"))
                            .cornerRadius(16)
                        if vm.description.isEmpty {
                            Text("Write a message…")
                                .foregroundColor(Color(hex: "#A3B18A").opacity(0.6))
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    /* Summary */
                    HStack {
                        Text("\(invitedCount) friend\(invitedCount == 1 ? "" : "s") invited")
                            .font(.subheadline).fontWeight(.medium)
                        Spacer()
                        if let first = vm.selectedFriends.first {
                            Circle()
                                .fill(Color(hex: "#F5F7F2"))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "person.crop.circle")   // placeholder avatar
                                        .resizable().scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    
                    /* Create button */
                    Button {
                        Task {
                            await vm.create()
                            if let kb = vm.createdKickback {
                                //                                showCamera = true      // proceed
                                kickbackMgr.activeKickbackID = kb.id   // announce
                                kickbackMgr.isHost          = true
                            }
                        }
                    } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(Color(hex: "#7B8C6A"))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#F5F7F2"))
                        .cornerRadius(16)
                    }
//                    .disabled(vm.title.isEmpty || invitedCount == 0)
                    .disabled(vm.title.isEmpty) // for testing without inviting any users
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationBarTitle("New Kickback", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showFriendPicker) {
                FriendPickerSheet(selection: $vm.selectedFriends)
            }
            //            .fullScreenCover(isPresented: $showCamera) {
            //                CameraCaptureView(capturedImages: $capturedImages)
            //            }
        }
    }
        // MARK: – Invitee chips
        var inviteeChips: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.selectedFriends) { friend in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(hex: "#F5F7F2"))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.crop.circle")
                                        .resizable().scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.gray)
                                )
                            Text(friend.full_name ?? friend.username)
                                .font(.subheadline).foregroundColor(.black)
                            Button {
                                vm.selectedFriends.removeAll { $0.id == friend.id }
                            } label: {
                                Image(systemName: "xmark").foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 6).padding(.horizontal, 12)
                        .background(Color(hex: "#F5F7F2")).cornerRadius(12)
                    }
                }
            }
        }
    }

