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
            Color.white
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
    private let worryInputFontSize: CGFloat = 24 // 1.5rem (24px, 16px = 1rem 기준) — 임팩트 있는 가독
    
    @Binding var worryText: String
    @State private var showCompleteButton = false
    @State private var hasScheduledButtonAppearance = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // 구겨진 종이 배경
            Image("PaperBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // 인풋 영역: 필드는 안 보이게, placeholder만 권유 멘트
                ZStack(alignment: .top) {
                    TextEditor(text: $worryText)
                        .frame(height: 200)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .font(.system(size: worryInputFontSize))
                        .multilineTextAlignment(.center)
                    
                    if worryText.isEmpty {
                        Text("걱정을 써보세요")
                            .font(.system(size: worryInputFontSize))
                            .foregroundColor(.black.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 24)
                
                Button(action: onComplete) {
                    Text("다 썼어")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.7),
                                                .white.opacity(0.25)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.9),
                                                .white.opacity(0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 40)
                .opacity(showCompleteButton ? 1 : 0)
                .offset(y: showCompleteButton ? 0 : 12)
                .allowsHitTesting(showCompleteButton)
                .animation(.easeOut(duration: 0.5), value: showCompleteButton)
                
                Spacer()
            }
            .padding()
        }
        .onChange(of: worryText) { _, newValue in
            let hasInput = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if hasInput, !hasScheduledButtonAppearance {
                hasScheduledButtonAppearance = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    showCompleteButton = true
                }
            }
        }
    }
}

// MARK: - Selection View (2x2 그리드 + 리퀴드/비눗방울 스타일)
struct SelectionView: View {
    @Binding var selectedMethod: String?
    
    let onSelect: (String) -> Void
    
    let methods = ["파쇄", "태우기", "물에 띄우기", "바람에 날리기"]
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("어떻게 없앨까요?")
                .font(.title2)
                .foregroundColor(.black)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(methods, id: \.self) { method in
                    Button(action: {
                        onSelect(method)
                    }) {
                        Text(method)
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(
                                ZStack {
                                    // 비눗방울/리퀴드: 반투명 유리 + 상단 하이라이트
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.7),
                                                    .white.opacity(0.25)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial)
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(0.9),
                                                    .white.opacity(0.4)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            
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
                .foregroundColor(.black)
            
            Text("[\(selectedMethod)]로 없애는 중...")
                .font(.title3)
                .foregroundColor(.black)
            
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
                    .foregroundColor(.black)
                    .transition(.opacity)
            }
            
            if showButton {
                Button(action: onReset) {
                    Text("다른 걱정 없애기")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.7),
                                                .white.opacity(0.25)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.9),
                                                .white.opacity(0.4)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
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
