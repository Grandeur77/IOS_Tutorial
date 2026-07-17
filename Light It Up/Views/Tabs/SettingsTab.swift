import SwiftUI
import AudioToolbox // <-- Added to trigger test sounds

struct SettingsTab: View {
    // Player Profile States
    @AppStorage("PlayerDisplayName") private var displayName = "Guest"
    @State private var tempName = ""
    
    // Gameplay States
    @AppStorage("LightItUpRoundLength") private var roundLengthSeconds = 60.0
    
    // Sound & Haptics States
    @AppStorage("GameSoundsEnabled") private var isSoundEnabled = true
    @AppStorage("HapticFeedbackEnabled") private var isHapticsEnabled = true
    
    // Notification States
    @AppStorage("DailyReminderEnabled") private var isReminderEnabled = false
    @AppStorage("DailyReminderHour") private var reminderHour = 19
    @AppStorage("DailyReminderMinute") private var reminderMinute = 0
    
    @State private var selectedTime: Date = Date()
    @State private var showResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    // SECTION 1: Player Profile
                    Section(header: Text("Player Profile").foregroundColor(.accentColor)) {
                        HStack(spacing: 16) {
                            // Avatar Icon Box
                            Image(systemName: "person.crop.circle.badge.checkmark.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.accentColor)
                                .frame(width: 48, height: 48)
                                .background(Color.accentColor.opacity(0.12))
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(displayName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Guest Account")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Edit display name field
                        TextField("Display Name", text: $tempName)
                            .foregroundColor(.white)
                            .submitLabel(.done)
                        
                        Button("Save Display Name") {
                            let trimmed = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                displayName = trimmed
                            }
                            hideKeyboard()
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.accentColor)
                        
                        Button("Log Out", role: .destructive) {
                            displayName = "Guest"
                            tempName = ""
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                    
                    // SECTION 2: Gameplay Settings
                    Section(header: Text("Gameplay").foregroundColor(.accentColor), footer: Text("Round length adjusts Light It Up level-up thresholds.").foregroundColor(.gray)) {
                        Picker("Round Length", selection: $roundLengthSeconds) {
                            Text("30 Seconds").tag(30.0)
                            Text("60 Seconds (Default)").tag(60.0)
                            Text("90 Seconds").tag(90.0)
                        }
                        .pickerStyle(.menu)
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                    .foregroundColor(.white)
                    
                    // SECTION 3: Sound & Haptics
                    Section(header: Text("Sound & Haptics").foregroundColor(.accentColor)) {
                        Toggle(isOn: $isSoundEnabled) {
                            Label("Game Sounds", systemImage: "speaker.wave.3.fill")
                        }
                        .tint(.accentColor)
                        
                        Toggle(isOn: $isHapticsEnabled) {
                            Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
                        }
                        .tint(.accentColor)
                        
                        Button(action: triggerTestAlert) {
                            Label("Test Sound & Haptics", systemImage: "waveform")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.accentColor)
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                    .foregroundColor(.white)
                    
                    // SECTION 4: Daily Reminder Notifications
                    Section(header: Text("Daily Reminders").foregroundColor(.accentColor)) {
                        Toggle(isOn: $isReminderEnabled) {
                            Label("Enable Daily Reminder", systemImage: "bell.fill")
                        }
                        .tint(.accentColor)
                        .onChange(of: isReminderEnabled) { newValue in
                            if newValue {
                                NotificationService.shared.requestPermission()
                                rescheduleNotification()
                            } else {
                                NotificationService.shared.cancelDailyReminders()
                            }
                        }
                        
                        if isReminderEnabled {
                            DatePicker("Remind Me At", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .onChange(of: selectedTime) { newTime in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                                    reminderHour = components.hour ?? 19
                                    reminderMinute = components.minute ?? 0
                                    rescheduleNotification()
                                }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                    .foregroundColor(.white)
                    
                    // SECTION 5: Danger Zone
                    Section(header: Text("Danger Zone").foregroundColor(.red)) {
                        Button(role: .destructive, action: {
                            showResetConfirmation = true
                        }) {
                            Label("Reset All Statistics", systemImage: "trash.fill")
                                .fontWeight(.semibold)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadSavedTime()
                tempName = displayName == "Guest" ? "" : displayName
            }
            .alert("Reset All Statistics?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Everything", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your high scores, statistics, map coordinates, and game sessions. This action cannot be undone.")
            }
        }
    }
    
    private func rescheduleNotification() {
        NotificationService.shared.scheduleDailyNotification(at: reminderHour, minute: reminderMinute)
    }
    
    private func loadSavedTime() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = reminderHour
        components.minute = reminderMinute
        selectedTime = Calendar.current.date(from: components) ?? Date()
    }
    
    // System Sound and Haptic alert test callback
    private func triggerTestAlert() {
        if isSoundEnabled {
            // Plays a standard system notification sound (1004 is mail sent alert sound)
            AudioServicesPlaySystemSound(1004)
        }
        if isHapticsEnabled {
            // Trigger a physical vibration pop
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    private func resetAllData() {
        GameSessionStore.clearAllSessions()
        UserDefaults.standard.removeObject(forKey: "LightItUpHighScore")
        UserDefaults.standard.removeObject(forKey: "QuizRushHighScore")
        UserDefaults.standard.removeObject(forKey: "TapFrenzyHighScore_Default")
        UserDefaults.standard.removeObject(forKey: "TapFrenzyHighScore_Combo System")
        UserDefaults.standard.removeObject(forKey: "TapFrenzyHighScore_Trap Colour")
        UserDefaults.standard.removeObject(forKey: "TapFrenzyHighScore_Moving Target")
        UserDefaults.standard.removeObject(forKey: "TapFrenzyHighScore_Shrinking Button")
        UserDefaults.standard.removeObject(forKey: "AppStorageKeyForTapFrenzyHighScore_Bonus Burst")
        
        isReminderEnabled = false
        NotificationService.shared.cancelDailyReminders()
        displayName = "Guest"
        tempName = ""
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SettingsTab()
}
