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

    enum Field {
        case username, password
    }
    @FocusState private var focusedField: Field?
    
    @State private var animateBlob = false
    
    // Access active iOS ColorScheme (light or dark)
    @Environment(\.colorScheme) var colorScheme
    
    // Colors helper for adaptive styling
    private var baseBackgroundColor: Color {
        colorScheme == .light ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color.black
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .light ? Color(UIColor.secondarySystemGroupedBackground) : Color.white.opacity(0.03)
    }
    
    private var cardBorderColor: Color {
        colorScheme == .light ? Color.black.opacity(0.06) : Color.white.opacity(0.08)
    }
    
    var body: some View {
        ZStack {
            baseBackgroundColor.ignoresSafeArea()
            
            // Neon mesh blobs only visible in dark mode to preserve high-contrast layout
            if colorScheme == .dark {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.18))
                        .frame(width: 320, height: 320)
                        .blur(radius: 90)
                        .offset(x: animateBlob ? -70 : 70, y: animateBlob ? -90 : 90)
                    
                    Circle()
                        .fill(Color.yellow.opacity(0.10))
                        .frame(width: 280, height: 280)
                        .blur(radius: 80)
                        .offset(x: animateBlob ? 90 : -90, y: animateBlob ? 110 : -110)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                        animateBlob.toggle()
                    }
                }
                .ignoresSafeArea()
            }
            
            // Main Contents
            ScrollView(showsIndicators: false) {
                VStack(spacing: 38) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Logo Section
                    VStack(spacing: 16) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.accentColor)
                            .shadow(color: .accentColor.opacity(0.5), radius: 12)
                        
                        Text("GAME ARCADIA")
                            .font(.system(size: 30, weight: .black, design: .monospaced))
                            .foregroundColor(colorScheme == .light ? .orange : .yellow)
                            .tracking(5)
                            .shadow(
                                color: (colorScheme == .light ? Color.orange.opacity(0.2) : Color.yellow.opacity(0.5)),
                                radius: 8
                            )
                        
                        Text(isSignUpMode ? "Create your local arcade account" : "Sign in to record your stats")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            
                            // Username Input Field
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.subheadline)
                                    .foregroundColor(focusedField == .username ? .accentColor : .secondary)
                                
                                TextField(
                                    "",
                                    text: $username,
                                    prompt: Text("Username or Email")
                                        .foregroundColor(.secondary.opacity(0.5))
                                )
                                .font(.body)
                                .foregroundColor(.primary)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focusedFieldBind(.username, binding: $focusedField)
                            }
                            .padding()
                            .background(colorScheme == .light ? Color.white.opacity(0.05) : Color.white.opacity(0.01))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        focusedField == .username ? Color.accentColor : cardBorderColor,
                                        lineWidth: 1
                                    )
                                    .shadow(color: focusedField == .username ? .accentColor.opacity(0.25) : .clear, radius: 4)
                            )
                            .animation(.easeOut(duration: 0.2), value: focusedField)
                            
                            // Password Input Field
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.subheadline)
                                    .foregroundColor(focusedField == .password ? .accentColor : .secondary)
                                
                                SecureField(
                                    "",
                                    text: $password,
                                    prompt: Text("Password")
                                        .foregroundColor(.secondary.opacity(0.5))
                                )
                                .font(.body)
                                .foregroundColor(.primary)
                                .focusedFieldBind(.password, binding: $focusedField)
                            }
                            .padding()
                            .background(colorScheme == .light ? Color.white.opacity(0.05) : Color.white.opacity(0.01))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        focusedField == .password ? Color.accentColor : cardBorderColor,
                                        lineWidth: 1
                                    )
                                    .shadow(color: focusedField == .password ? .accentColor.opacity(0.25) : .clear, radius: 4)
                            )
                            .animation(.easeOut(duration: 0.2), value: focusedField)
                        }
                        
                        Button(action: handleAction) {
                            Text(isSignUpMode ? "CREATE ACCOUNT" : "LOGIN")
                                .font(.system(.headline, design: .monospaced).bold())
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.yellow, Color.orange.opacity(0.9)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: .yellow.opacity(0.45), radius: 8)
                        }
                        
                        // Toggle Mode Link
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isSignUpMode.toggle()
                            }
                        }) {
                            Text(isSignUpMode ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(24)
                    .background(cardBackgroundColor)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.accentColor.opacity(0.5), (colorScheme == .light ? Color.orange.opacity(0.3) : Color.yellow.opacity(0.2))],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 10)
                    
                    // Guest Option
                    Button(action: {
                        displayName = "Guest"
                        withAnimation {
                            isGuestMode = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text("Play as Guest")
                                .font(.system(size: 13, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                        }
                        .foregroundColor(colorScheme == .light ? .orange : .yellow)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(colorScheme == .light ? Color.orange.opacity(0.08) : Color.yellow.opacity(0.06))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(colorScheme == .light ? Color.orange.opacity(0.2) : Color.yellow.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 20)
                }
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

// Focused field bind extension
extension View {
    func focusedFieldBind(_ field: LoginView.Field, binding: FocusState<LoginView.Field?>.Binding) -> some View {
        self.focused(binding, equals: field)
    }
}

#Preview {
    LoginView(isGuestMode: .constant(false))
}
