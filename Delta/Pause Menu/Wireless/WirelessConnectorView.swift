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
    
    var body: some View {
        Form {
            Section(header: Text("Cloudflare Relay")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Relay Server")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Server URL", text: $manager.serverURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(manager.state != .disconnected && !isErrorState)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Room Code")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        TextField("Room Code", text: $manager.roomCode)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .disabled(manager.state != .disconnected && !isErrorState)
                        
                        Button("Random") {
                            manager.roomCode = GBAWirelessManager.generateRandomRoomCode()
                        }
                        .buttonStyle(.bordered)
                        .tint(Color(uiColor: .deltaPurple))
                        .disabled(manager.state != .disconnected && !isErrorState)
                    }
                }
                
                Picker("Role", selection: $manager.role) {
                    ForEach(GBAWirelessManager.Role.allCases) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(manager.state != .disconnected && !isErrorState)
                
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
            
            Section(header: Text("Connection Status")) {
                HStack {
                    statusIndicator
                    Text(manager.state.description)
                        .font(.subheadline)
                        .foregroundColor(statusTextColor)
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
        case .connecting, .hostListening, .joinerProbing:
            ProgressView().scaleEffect(0.7)
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
        case .error:
            return .red
        case .connecting, .hostListening, .joinerProbing:
            return .orange
        case .disconnected:
            return .primary
        }
    }
}
