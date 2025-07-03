import SwiftUI

struct PomodoroView: View {
    @ObservedObject var pomodoroModel: PomodoroModel
    @EnvironmentObject var vm: BoringViewModel
    @State private var showingSettings = false

    var body: some View {
        panel
    }
    
    var panel: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
            .foregroundStyle(.white.opacity(0.1))
            .overlay {
                content
                    .padding(20)
            }
    }
    
    var content: some View {
        VStack(alignment: .center, spacing: 16) {
            // Status indicator
            HStack(spacing: 10) {
                Circle()
                    .fill(pomodoroModel.currentState == .work ? Color.red : 
                          pomodoroModel.currentState == .shortBreak ? Color.green :
                          pomodoroModel.currentState == .longBreak ? Color.blue : Color.gray)
                    .frame(width: 12, height: 12)
                
                Text(stateText)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            // Timer display
            Text(formatTime(pomodoroModel.remainingTime))
                .font(.system(size: 48, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.vertical, 8)
            
            // Counter
            Text("Pomodoros: \(pomodoroModel.completedPomodoros)")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .padding(.bottom, 4)
            
            // Main controls
            HStack(spacing: 24) {
                Button(action: {
                    if pomodoroModel.isTimerRunning {
                        pomodoroModel.pause()
                    } else {
                        pomodoroModel.start()
                    }
                }) {
                    HStack {
                        Image(systemName: pomodoroModel.isTimerRunning ? "pause.fill" : "play.fill")
                        Text(pomodoroModel.isTimerRunning ? "Pause" : "Start")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(minWidth: 100)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    pomodoroModel.reset()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(minWidth: 100)
                }
                .buttonStyle(.bordered)
            }
            
            // Settings button
            Button(action: {
                showingSettings.toggle()
            }) {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
            
            if showingSettings {
                simplifiedSettings
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            pomodoroModel.loadSettings()
        }
    }
    
    var stateText: String {
        switch pomodoroModel.currentState {
        case .idle:
            return "Ready"
        case .work:
            return "Working"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
    
    var simplifiedSettings: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Work:")
                    .foregroundStyle(.white)
                Spacer()
                Text("\(pomodoroModel.settings.workDuration / 60) min")
                    .foregroundStyle(.secondary)
                Stepper("", value: $pomodoroModel.settings.workDuration, in: 60...3600, step: 60)
                    .labelsHidden()
            }
            
            HStack {
                Text("Break:")
                    .foregroundStyle(.white)
                Spacer()
                Text("\(pomodoroModel.settings.shortBreakDuration / 60) min")
                    .foregroundStyle(.secondary)
                Stepper("", value: $pomodoroModel.settings.shortBreakDuration, in: 60...1800, step: 60)
                    .labelsHidden()
            }
            
            Button("Save") {
                pomodoroModel.saveSettings()
                showingSettings = false
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct PomodoroView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            PomodoroView(pomodoroModel: PomodoroModel())
                .environmentObject(BoringViewModel())
        }
    }
} 
