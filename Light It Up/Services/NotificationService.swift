import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    private override init() {
        super.init()
        // Sets delegate so that foreground notifications show alert banners
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Request local notification permissions from the user
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedules a daily repeating local notification at a specific hour and minute
    func scheduleDailyNotification(at hour: Int, minute: Int) {
        // Cancel existing reminders first
        cancelDailyReminders()
        
        let content = UNMutableNotificationContent()
        content.title = "Arcade Time! 🎮"
        content.body = "Time to insert a coin and beat your high scores in Game Arcadia!"
        content.sound = .default
        
        // Match the user's selected hour and minute
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Repeating daily trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedules a test notification to trigger in 5 seconds for demonstration
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Reminder! ⚡️"
        content.body = "This is a quick 5-second test notification from Game Arcadia."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let request = UNNotificationRequest(identifier: "test_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Cancels the daily reminder
    func cancelDailyReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }
    
    // Delegate method to present notification even when app is active in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
