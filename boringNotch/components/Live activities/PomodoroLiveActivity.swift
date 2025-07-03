import SwiftUI

struct PomodoroLiveActivity: View {
    @ObservedObject var pomodoroModel: PomodoroModel
    @EnvironmentObject var vm: BoringViewModel
    @State private var isHovering: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            // Left side - Timer icon
            Image(systemName: "timer")
                .foregroundColor(pomodoroModel.currentState == .work ? .red : (pomodoroModel.currentState == .shortBreak || pomodoroModel.currentState == .longBreak ? .green : .gray))
                .frame(width: max(0, vm.effectiveClosedNotchHeight - 12), height: max(0, vm.effectiveClosedNotchHeight - 12))
            
            // Middle - Spacer with black background
            Rectangle()
                .fill(.black)
                .frame(width: vm.closedNotchSize.width)
            
            // Right side - Timer text
            HStack {
                Spacer() // Push the timer text to the right
                Text(formatTime(pomodoroModel.remainingTime))
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.trailing, 0) // Add some padding from the edge
            }
            .frame(width: max(0, vm.effectiveClosedNotchHeight + 30), height: max(0, vm.effectiveClosedNotchHeight - 12))
        }
        .frame(height: vm.effectiveClosedNotchHeight + (isHovering ? 8 : 0), alignment: .center)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct PomodoroLiveActivity_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroLiveActivity(pomodoroModel: PomodoroModel())
            .environmentObject(BoringViewModel())
            .background(Color.gray)
    }
} 
