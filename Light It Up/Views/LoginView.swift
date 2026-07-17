import SwiftUI

struct LoginView: View {
    @Binding var isGuestMode: Bool
    
    @AppStorage("PlayerDisplayName") private var displayName = "Guest"
    @AppStorage("IsUserLoggedIn") private var isUserLoggedIn = false
    
    @State private var isSignUpMode = false
    @State private var username = ""
    @State private var password = ""
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 36) {
                Spacer()
                
                // Iconic Arcade Logo/Header
                VStack(spacing: 12) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                        .shadow(color: .accentColor.opacity(0.6), radius: 10)
                    
                    Text("GAME ARCADIA")
                        .font(.system(size: 34, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                        .tracking(4)
                        .shadow(color: Color.yellow.opacity(0.6), radius: 8)
                    
                    Text(isSignUpMode ? "Create your local arcade account" : "Sign in to record your stats")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Input Fields
                VStack(spacing: 16) {
                    // Username / Email input field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 20)
                        
                        TextField("Username or Email", text: $username)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    
                    // Password input field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 20)
                        
                        SecureField("Password", text: $password)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                
                // Action Buttons
                VStack(spacing: 16) {
                    // Action Trigger
                    Button(action: handleAction) {
                        Text(isSignUpMode ? "Create Account" : "Insert Coin & Login")
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(12)
                            .shadow(color: .accentColor.opacity(0.4), radius: 8)
                    }
                    .padding(.horizontal, 24)
                    
                    // Mode Toggle Button
                    Button(action: {
                        withAnimation {
                            isSignUpMode.toggle()
                        }
                    }) {
                        Text(isSignUpMode ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Guest Mode Entry button
                Button(action: {
                    displayName = "Guest"
                    withAnimation {
                        isGuestMode = true
                    }
                }) {
                    HStack(spacing: 6) {
                        Text("Play as Guest")
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.yellow.opacity(0.08))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom, 24)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isSignUpMode ? "Sign Up Error" : "Login Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Handles registration and authentication checks
    private func handleAction() {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !u.isEmpty, !p.isEmpty else {
            alertMessage = "Username and Password fields cannot be empty."
            showAlert = true
            return
        }
        
        if isSignUpMode {
            let success = AuthService.shared.register(username: u, password: p)
            if success {
                displayName = u
                withAnimation {
                    isUserLoggedIn = true
                }
            } else {
                alertMessage = "Username already exists. Please choose another one."
                showAlert = true
            }
        } else {
            let success = AuthService.shared.login(username: u, password: p)
            if success {
                displayName = u
                withAnimation {
                    isUserLoggedIn = true
                }
            } else {
                alertMessage = "Incorrect username/email or password. Please try again."
                showAlert = true
            }
        }
    }
}

#Preview {
    LoginView(isGuestMode: .constant(false))
}
