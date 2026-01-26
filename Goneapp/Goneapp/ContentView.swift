//
//  ContentView.swift
//  Goneapp
//
//  Created by 강주은 on 1/26/26.
//

import SwiftUI

// MARK: - App Stage Enum
enum AppStage {
    case input
    case selection
    case destruction
    case gone
}

struct ContentView: View {
    // MARK: - State Management
    @State private var currentStage: AppStage = .input
    @State private var worryText: String = ""
    @State private var selectedMethod: String?
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Stage-based View Switching
            Group {
                switch currentStage {
                case .input:
                    InputView(
                        worryText: $worryText,
                        onComplete: {
                            if !worryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStage = .selection
                                }
                            }
                        }
                    )
                    .transition(.opacity)
                    
                case .selection:
                    SelectionView(
                        selectedMethod: $selectedMethod,
                        onSelect: { method in
                            selectedMethod = method
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStage = .destruction
                            }
                        }
                    )
                    .transition(.opacity)
                    
                case .destruction:
                    DestructionView(
                        worryText: worryText,
                        selectedMethod: selectedMethod ?? "",
                        onComplete: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStage = .gone
                            }
                        }
                    )
                    .transition(.opacity)
                    
                case .gone:
                    GoneView(
                        onReset: {
                            worryText = ""
                            selectedMethod = nil
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStage = .input
                            }
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Input View
struct InputView: View {
    @Binding var worryText: String
    
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("걱정을 적어보세요")
                .font(.title2)
                .foregroundColor(.white)
            
            TextEditor(text: $worryText)
                .frame(height: 200)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
            
            Button(action: onComplete) {
                Text("다 썼어")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Selection View
struct SelectionView: View {
    @Binding var selectedMethod: String?
    
    let onSelect: (String) -> Void
    
    let methods = ["파쇄", "태우기", "물에 띄우기", "바람에 날리기"]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("어떻게 없앨까요?")
                .font(.title2)
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                ForEach(methods, id: \.self) { method in
                    Button(action: {
                        onSelect(method)
                    }) {
                        Text(method)
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Destruction View
struct DestructionView: View {
    let worryText: String
    let selectedMethod: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("'\(worryText)'를")
                .font(.title3)
                .foregroundColor(.white)
            
            Text("[\(selectedMethod)]로 없애는 중...")
                .font(.title3)
                .foregroundColor(.white)
            
            // TODO: 여기에 나중에 SpriteKit 애니메이션이 들어갈 자리
            
            Spacer()
        }
        .padding()
        .onAppear {
            // 3초 후 자동으로 .gone 단계로 전환
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onComplete()
            }
        }
    }
}

// MARK: - Gone View
struct GoneView: View {
    let onReset: () -> Void
    
    @State private var showText = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if showText {
                Text("gone.")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .transition(.opacity)
            }
            
            if showButton {
                Button(action: onReset) {
                    Text("다른 걱정 없애기")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .transition(.opacity)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            // 텍스트 페이드 인
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
            
            // 2초 후 버튼 페이드 인
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showButton = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
