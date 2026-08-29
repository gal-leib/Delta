//
//  WirelessConnectorView.swift
//  Delta
//
//  Created for GBA Wireless Adapter (RFU) Online Relay support.
//

import SwiftUI
import GBADeltaCore

extension WirelessConnectorView {
    class HostingController: UIHostingController<AnyView> {
        required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        init() {
            super.init(rootView: AnyView(EmptyView()))
            let view = WirelessConnectorView(dismissAction: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            self.rootView = AnyView(view)
            self.view.backgroundColor = .clear
            self.title = NSLocalizedString("Wireless Adapter", comment: "")
        }
    }
}

struct WirelessConnectorView: View {
    @ObservedObject private var manager = GBAWirelessManager.shared
    var dismissAction: (() -> Void)?
    
    @SwiftUI.State private var showAdvancedSettings: Bool = false
    @SwiftUI.State private var copiedToClipboard: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Room Connection"), footer: Text("Both players simply enter the same Room Code and tap Connect. Roles and sessions are negotiated automatically.")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Room Code")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        TextField("e.g. trade-abc123", text: $manager.roomCode)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .disabled(manager.state != .disconnected && !isErrorState)
                        
                        Button(action: {
                            UIPasteboard.general.string = manager.roomCode
                            copiedToClipboard = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copiedToClipboard = false
                            }
                        }) {
                            Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                        .tint(Color(uiColor: .deltaPurple))
                        
                        Button("Random") {
                            manager.roomCode = GBAWirelessManager.generateRandomRoomCode()
                        }
                        .buttonStyle(.bordered)
                        .tint(Color(uiColor: .deltaPurple))
                        .disabled(manager.state != .disconnected && !isErrorState)
                    }
                }
            }
            
            Section(header: Text("Connection Status")) {
                HStack(spacing: 12) {
                    statusIndicator
                    Text(manager.state.description)
                        .font(.subheadline)
                        .foregroundColor(statusTextColor)
                }
                .padding(.vertical, 2)
                
                if manager.state.isConnected || manager.peerCount > 0 {
                    HStack {
                        Text("Room Presence")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(manager.peerCount)/2 Players")
                            .font(.footnote)
                            .bold()
                            .foregroundColor(manager.peerCount >= 2 ? .green : .orange)
                    }
                    
                    if let role = manager.assignedRole {
                        HStack {
                            Text("Assigned Role")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(role.capitalized)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                HStack {
                    Text("Traffic")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Sent: \(manager.stats.messagesSent) | Recv: \(manager.stats.messagesReceived)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Retransmissions")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(manager.stats.retransmissions)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                if manager.state == .disconnected || isErrorState {
                    Button(action: {
                        manager.connect()
                    }) {
                        HStack {
                            Spacer()
                            Label("Connect", systemImage: "antenna.radiowaves.left.and.right")
                                .bold()
                            Spacer()
                        }
                    }
                    .tint(Color(uiColor: .deltaPurple))
                } else {
                    Button(role: .destructive, action: {
                        manager.disconnect()
                    }) {
                        HStack {
                            Spacer()
                            Label("Disconnect", systemImage: "xmark.circle")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            
            Section(header: HStack {
                Text("Advanced Settings")
                Spacer()
                Button(showAdvancedSettings ? "Hide" : "Show") {
                    showAdvancedSettings.toggle()
                }
                .font(.caption)
            }) {
                if showAdvancedSettings {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Relay Server URL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Server URL", text: $manager.serverURL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .disabled(manager.state != .disconnected && !isErrorState)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Room Token (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        SecureField("Token", text: $manager.roomToken)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .disabled(manager.state != .disconnected && !isErrorState)
                    }
                }
            }
        }
        .navigationTitle(Text("Wireless Adapter"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isErrorState: Bool {
        if case .error = manager.state { return true }
        return false
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        switch manager.state {
        case .disconnected:
            Circle().fill(Color.gray).frame(width: 10, height: 10)
        case .connecting:
            ProgressView().scaleEffect(0.7)
        case .waitingForPartner:
            Circle().fill(Color.blue).frame(width: 10, height: 10)
        case .connected:
            Circle().fill(Color.green).frame(width: 10, height: 10)
        case .error:
            Circle().fill(Color.red).frame(width: 10, height: 10)
        }
    }
    
    private var statusTextColor: Color {
        switch manager.state {
        case .connected:
            return .green
        case .waitingForPartner:
            return .blue
        case .error:
            return .red
        case .connecting:
            return .orange
        case .disconnected:
            return .primary
        }
    }
}
