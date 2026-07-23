import SwiftUI
import AudioToolbox

struct SettingsTab: View {
    @Binding var isGuestMode: Bool
    
    @AppStorage("IsUserLoggedIn") private var isUserLoggedIn = false
    
    // Read and write the global theme setting (Defaults to Dark)
    @AppStorage("AppTheme") private var appTheme: AppTheme = .dark
    
    // Access active iOS ColorScheme (light or dark)
    @Environment(\.colorScheme) var colorScheme
    
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
    
    // Alerts
    @State private var showResetConfirmation = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    
    // Colors helper for adaptive design
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var cardBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.05)
    }
    
    private var headerTextColor: Color {
        colorScheme == .light ? Color.orange : Color.yellow
    }
    
    private var dividerColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.08)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                baseBackgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        
                        // SECTION 1: Theme Settings Card (Phase 13 Selector)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("THEME SETTINGS")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 16) {
                                HStack(spacing: 8) {
                                    ForEach(AppTheme.allCases) { option in
                                        let isSelected = appTheme == option
                                        let fgColor = isSelected ? (colorScheme == .light ? Color.white : Color.black) : Color.primary
                                        let bgColor = isSelected ? Color.accentColor : Color.white.opacity(colorScheme == .light ? 0.05 : 0.03)
                                        let strokeColor = isSelected ? Color.accentColor : cardBorderColor
                                        
                                        Button(action: {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                appTheme = option
                                            }
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: iconForTheme(option))
                                                    .font(.subheadline)
                                                Text(option.rawValue)
                                                    .font(.caption.bold())
                                            }
                                            .foregroundColor(fgColor)
                                            .padding(.vertical, 10)
                                            .frame(maxWidth: .infinity)
                                            .background(bgColor)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .strokeBorder(strokeColor, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(cardBackgroundColor)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(cardBorderColor, lineWidth: 1)
                            )
                        }
                        
                        // SECTION 2: Player Profile Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PLAYER PROFILE")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    Image(systemName: "person.crop.circle.badge.checkmark.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.accentColor)
                                        .frame(width: 48, height: 48)
                                        .background(Color.accentColor.opacity(0.12))
                                        .cornerRadius(12)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(displayName)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(isUserLoggedIn ? "Registered Account" : "Guest Account")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.bottom, 4)
                                
                                Divider().background(dividerColor)
                                
                                // Input Field
                                TextField(
                                    "",
                                    text: $tempName,
                                    prompt: Text("Display Name").foregroundColor(.secondary.opacity(0.5))
                                )
                                .font(.body)
                                .foregroundColor(.primary)
                                .submitLabel(.done)
                                .padding(.vertical, 8)
                                
                                HStack(spacing: 12) {
                                    Button("Save Name") {
                                        let trimmed = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        if !trimmed.isEmpty {
                                            if isUserLoggedIn {
                                                let oldName = displayName
                                                let success = AuthService.shared.updateUsername(from: oldName, to: trimmed)
                                                if success {
                                                    displayName = trimmed
                                                } else {
                                                    alertMessage = "Username already exists. Please choose a different one."
                                                    showErrorAlert = true
                                                }
                                            } else {
                                                displayName = trimmed
                                            }
                                        }
                                        hideKeyboard()
                                    }
                                    .font(.subheadline.bold())
                                    .foregroundColor(.accentColor)
                                    
                                    Spacer()
                                    
                                    Button("Log Out", role: .destructive) {
                                        displayName = "Guest"
                                        tempName = ""
                                        withAnimation {
                                            isUserLoggedIn = false
                                            isGuestMode = false
                                        }
                                    }
                                    .font(.subheadline.bold())
                                }
                            }
                            .padding(20)
                            .background(cardBackgroundColor)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(cardBorderColor, lineWidth: 1)
                            )
                        }
                        
                        // SECTION 3: Gameplay Settings
                        VStack(alignment: .leading, spacing: 14) {
                            Text("GAMEPLAY")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 16) {
                                Picker("Round Length", selection: $roundLengthSeconds) {
                                    Text("30 Seconds").tag(30.0)
                                    Text("60 Seconds (Default)").tag(60.0)
                                    Text("90 Seconds").tag(90.0)
                                }
                                .pickerStyle(.menu)
                                .tint(.accentColor)
                            }
                            .padding(20)
                            .background(cardBackgroundColor)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(cardBorderColor, lineWidth: 1)
                            )
                        }
                        
                        // SECTION 4: Sound & Haptics Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("SOUND & HAPTICS")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 20) {
                                Toggle(isOn: $isSoundEnabled) {
                                    Label("Game Sounds", systemImage: "speaker.wave.3.fill")
                                        .foregroundColor(.primary)
                                }
                                .tint(.accentColor)
                                
                                Divider().background(dividerColor)
                                
                                Toggle(isOn: $isHapticsEnabled) {
                                    Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
                                        .foregroundColor(.primary)
                                }
                                .tint(.accentColor)
                                
                                Divider().background(dividerColor)
                                
                                Button(action: triggerTestAlert) {
                                    Label("Test Sound & Haptics", systemImage: "waveform")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(20)
                            .background(cardBackgroundColor)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(cardBorderColor, lineWidth: 1)
                            )
                        }
                        
                        // SECTION 5: Daily Reminders Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("DAILY REMINDERS")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(headerTextColor)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 20) {
                                Toggle(isOn: $isReminderEnabled) {
                                    Label("Enable Daily Reminder", systemImage: "bell.fill")
                                        .foregroundColor(.primary)
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
                                    Divider().background(dividerColor)
                                    
                                    DatePicker("Remind Me At", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .tint(.accentColor)
                                        .onChange(of: selectedTime) { newTime in
                                            let components = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                                            reminderHour = components.hour ?? 19
                                            reminderMinute = components.minute ?? 0
                                            rescheduleNotification()
                                        }
                                }
                                
                                Divider().background(dividerColor)
                                
                                Button(action: {
                                    NotificationService.shared.requestPermission()
                                    NotificationService.shared.scheduleTestNotification()
                                }) {
                                    Label("Send Test Notification (5s Delay)", systemImage: "timer")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(20)
                            .background(cardBackgroundColor)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(cardBorderColor, lineWidth: 1)
                            )
                        }
                        
                        // SECTION 6: Danger Zone Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("DANGER ZONE")
                                .font(.system(size: 11, weight: .bold).monospaced())
                                .foregroundColor(.red)
                                .padding(.horizontal, 4)
                            
                            VStack {
                                Button(role: .destructive, action: {
                                    showResetConfirmation = true
                                }) {
                                    Label("Reset All Statistics", systemImage: "trash.fill")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.08))
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(20)
                            .background(cardBackgroundColor)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.red.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 110)
                }
                .alert("Error Updating Name", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
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
    
    private func iconForTheme(_ theme: AppTheme) -> String {
        switch theme {
        case .dark: return "moon.stars.fill"
        case .light: return "sun.max.fill"
        case .system: return "display"
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
    
    private func triggerTestAlert() {
        if isSoundEnabled {
            AudioServicesPlaySystemSound(1004)
        }
        if isHapticsEnabled {
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
        
        withAnimation {
            isUserLoggedIn = false
            isGuestMode = false
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
