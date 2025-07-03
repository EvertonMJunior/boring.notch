import Foundation
import SwiftUI

enum PomodoroState {
    case idle
    case work
    case shortBreak
    case longBreak
}

struct PomodoroSettings: Codable {
    var workDuration: Int = 25 * 60 // 25 minutes
    var shortBreakDuration: Int = 5 * 60 // 5 minutes
    var longBreakDuration: Int = 15 * 60 // 15 minutes
    var pomodorosBeforeLongBreak: Int = 4
}

class PomodoroModel: ObservableObject {
    @Published var settings: PomodoroSettings = PomodoroSettings()
    @Published var currentState: PomodoroState = .idle
    @Published var remainingTime: Int = 0
    @Published var completedPomodoros: Int = 0
    @Published var isTimerRunning: Bool = false

    private var timer: Timer?

    func start() {
        switch currentState {
        case .idle, .shortBreak, .longBreak:
            currentState = .work
            remainingTime = settings.workDuration
        case .work:
            // Already working, do nothing or pause? For now, let's restart.
            remainingTime = settings.workDuration
        }
        startTimer()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }

    func reset() {
        pause()
        currentState = .idle
        remainingTime = 0
        completedPomodoros = 0
    }

    private func startTimer() {
        timer?.invalidate() // Ensure any existing timer is stopped
        // Set remainingTime based on the current state
        switch currentState {
        case .work:
            remainingTime = settings.workDuration
        case .shortBreak:
            remainingTime = settings.shortBreakDuration
        case .longBreak:
            remainingTime = settings.longBreakDuration
        case .idle:
            // If idle, we might be starting a new work session or just unpausing.
            // If remainingTime is 0, it means we're starting a new session.
            if remainingTime == 0 {
                 currentState = .work // Default to starting a work session
                 remainingTime = settings.workDuration
            }
            // If remainingTime is > 0, it means we are unpausing, so keep existing remainingTime.
        }

        if remainingTime <= 0 { // if current state has 0 time, then transition to next state
            handleTimerCompletion()
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.handleTimerCompletion()
            }
        }
        isTimerRunning = true
    }

    private func handleTimerCompletion() {
        pause()
        switch currentState {
        case .work:
            completedPomodoros += 1
            if completedPomodoros % settings.pomodorosBeforeLongBreak == 0 {
                currentState = .longBreak
                remainingTime = settings.longBreakDuration
            } else {
                currentState = .shortBreak
                remainingTime = settings.shortBreakDuration
            }
        case .shortBreak, .longBreak:
            currentState = .idle // Or .work to automatically start next pomodoro? For now, .idle
            remainingTime = 0 // Or settings.workDuration if auto-starting
            // Consider a notification here
        case .idle:
            // Should not happen if timer completes in idle state
            return
        }
        // Automatically start the next timer if not idle, or if you want auto-start
        if currentState != .idle {
             startTimer()
        }
    }

    // Function to load settings (e.g., from UserDefaults)
    func loadSettings() {
        if let savedSettings = UserDefaults.standard.data(forKey: "pomodoroSettings") {
            let decoder = JSONDecoder()
            if let loadedSettings = try? decoder.decode(PomodoroSettings.self, from: savedSettings) {
                self.settings = loadedSettings
                // Reset timer according to new settings if needed
                if currentState == .work { remainingTime = settings.workDuration}
                // etc. for other states if you want them to update immediately
            }
        }
    }

    // Function to save settings (e.g., to UserDefaults)
    func saveSettings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "pomodoroSettings")
        }
    }
}

// Helper to format time for display
func formatTime(_ totalSeconds: Int) -> String {
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
} 
