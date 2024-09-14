//
//  VehicleDetail.swift
//  AmosLibrary
//
//  Created by Amos on 2024/8/18.
//

import SwiftUI

public struct DemoVehicleDetail: View {
    public let vehicle: VehicleStore
    public let command: CommandManager?
    @State private var stateType: VehicleStateType
    @State private var detail: TeslaStore?
    @State private var isLoading = false
    @State private var isWaking = false
    
    @State private var currentError: Error? = nil
    
    public init(
        vehicle: VehicleStore,
        command: CommandManager? = nil,
        detail: TeslaStore? = nil
    ) {
        self.vehicle = vehicle
        self.stateType = vehicle.stateType
        self.command = command
        self.detail = detail
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                if let currentError {
                    Section("发生错误") {
                        Label(
                            currentError.localizedDescription,
                            systemImage: "xmark.circle.fill"
                        )
                            .foregroundStyle(.red)
                    }
                }
                Section {
                    LabeledContent("名称", value: vehicle.display_name)
                    LabeledContent("状态", value: stateType.title)
                }
                if let detail {
                    Section {
                        Text(detail.description)
                    }
                }
                Section {
                    if stateType == .offline {
                        wakeupButton()
                    }
                    if stateType == .online {
                        updateButton()
                    }
                }
            }
            .navigationTitle("车辆详情")
        }
    }
    
    private func wakeupButton() -> some View {
        Button {
            wakeUp()
        } label: {
            LabeledContent("唤醒车辆") {
                if isWaking {
                    ProgressView()
                }
            }
        }
        .disabled(isWaking)
    }
    
    private func updateButton() -> some View {
        Button {
            fetchDetail()
        } label: {
            LabeledContent("更新数据") {
                if isLoading {
                    ProgressView()
                }
            }
        }
        .disabled(isLoading)
    }
}

extension DemoVehicleDetail {
    private func wakeUp() {
        guard let command else { return }
        Task {
            isWaking = true
            do {
                let isWake = try await command.wakeupVehicle(
                    vehicle.id
                )
                if isWake {
                    isWaking = false
                    stateType = .online
                    currentError = nil
                }else {
                    isWaking = false
                    currentError = TeslaError.customError(msg: "唤醒超时")
                }
            }catch {
                isWaking = false
                currentError = error
                debugPrint(error)
            }
        }
    }
    
    private func fetchDetail() {
        guard let command else { return }
        Task {
            isLoading = true
            do {
                detail = try await command.fetchVehicleData(
                    vehicle.id,
                    carName: vehicle.display_name
                )
                isLoading = false
                currentError = nil
            }catch {
                isLoading = false
                currentError = error
                debugPrint(error)
            }
        }
    }
}

#Preview {
    DemoVehicleDetail(
        vehicle: .example(),
        detail: exampleData()
    )
}
