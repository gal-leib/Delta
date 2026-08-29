//
//  GBACoreSettingsView.swift
//  Delta
//
//  Created by Caroline Moore on 8/18/25.
//  Copyright © 2025 Riley Testut. All rights reserved.
//

import SwiftUI

struct GBACoreSettingsView: CoreSettingsView
{
    var system: System { .gba }
    @Environment(\.openURL) var openURL
    
    var additionalSections: some View {
        Section(header: Text("Network")) {
            NavigationLink(destination: WirelessConnectorView()) {
                Label("Wireless Adapter (RFU)", systemImage: "antenna.radiowaves.left.and.right")
            }
        }
    }
}

#Preview {
    NavigationView {
        GBACoreSettingsView()
    }
}
