//
//  LanguageView.swift
//  Metal Detector IOS
//
//  Created by Lowbyte Studio on 27/11/2025.
//

import SwiftUI

struct Language: Identifiable {
    let id = UUID()
    let name: String
    let flagImageName: String
    var isDefault: Bool = false
}

struct LanguageView: View {
    var onBackTap: () -> Void
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedLanguage: String
    @State private var languages: [Language] = [
        Language(name: "english", flagImageName: "United States Flag", isDefault: true),
        Language(name: "francias", flagImageName: "France Flag"),
        Language(name: "polski", flagImageName: "Poland Flag"),
        Language(name: "vietnamese", flagImageName: "Vietnam Flag"),
        Language(name: "China", flagImageName: "China Flag"),
        Language(name: "Hongkong", flagImageName: "Hong Kong Flag"),
        Language(name: "indonesia", flagImageName: "Indonesia Flag"),
        Language(name: "Deutsh", flagImageName: "Germany Flag"),
        Language(name: "espanol", flagImageName: "Spain Flag"),
        Language(name: "italiano", flagImageName: "Italy Flag"),
        Language(name: "portugues", flagImageName: "Portugal Flag"),
        Language(name: "turkce", flagImageName: "Turkey Flag"),
        Language(name: "japan", flagImageName: "Japan Flag"),
        Language(name: "korean", flagImageName: "South Korea Flag"),
        Language(name: "thailand", flagImageName: "Thailand Flag"),
        Language(name: "Arabic", flagImageName: "Arabic Flag"),
        Language(name: "Hindi", flagImageName: "India Flag"),
        Language(name: "Philipino", flagImageName: "Philippines Flag"),
        Language(name: "malay", flagImageName: "Malaysia Flag")
    ]
    
    init(onBackTap: @escaping () -> Void) {
        self.onBackTap = onBackTap
        // Initialize selected language from current app language
        let currentCode = LocalizationManager.shared.currentLanguage
        _selectedLanguage = State(initialValue: LocalizationManager.shared.languageName(for: currentCode))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    // Title - Centered
                    Text(LocalizedString.selectYourLanguage.localized)
                        .font(.custom("Zodiak", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Done Button
                    Button(action: {
                        onBackTap()
                    }) {
                        Text(LocalizedString.done.localized)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 40)
                .padding(.bottom, 12)
                
                // Language List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(languages) { language in
                            LanguageRow(
                                language: language,
                                isSelected: selectedLanguage.lowercased() == language.name.lowercased(),
                                isDefault: language.isDefault
                            ) {
                                selectedLanguage = language.name
                                // Change app language
                                let languageCode = localizationManager.languageCode(for: language.name)
                                localizationManager.setLanguage(languageCode)
                            }
                        }
                    }
                    .padding(.horizontal, 24.5) // (365 - 316) / 2 = 24.5 for 365px width list
                    .padding(.top, 0)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    let isDefault: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 14) {
                // Flag Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 255/255, green: 8/255, blue: 69/255).opacity(0.12),
                                    Color(red: 255/255, green: 176/255, blue: 153/255).opacity(0.12)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 30, height: 30)
                    
                    // Flag Image (User will provide flag assets)
                    Image(language.flagImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                }
                
                // Language Name
                Text(language.name)
                    .font(.custom("Manrope_Bold", size: 14))
                    .foregroundColor(.white)
                    .textCase(.lowercase)
                
                Spacer()
                
                // Default Label (only for default language)
                if isDefault && isSelected {
                    Text(LocalizedString.defaultLabel.localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 16, height: 16)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.trailing, 6)
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .frame(maxWidth: 365) // Fixed width as per Figma
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 43/255, green: 43/255, blue: 43/255)) // #2b2b2b
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LanguageView(onBackTap: {})
}

