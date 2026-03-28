---
id: SKL-0007
name: Mobile Development
description: |
  Build mobile app screens, navigation, and platform-specific features. Supports
  three platforms: React Native + Expo (cross-platform), Swift/SwiftUI (native iOS),
  and Kotlin/Jetpack Compose (native Android). Use this skill when a mobile task
  is ready for implementation.
version: 2.0
owner: builder
triggers:
  - MOBILE_TASK_READY
inputs:
  - Task description (from STATE.md)
  - .claude/project/knowledge/DECISIONS.md
  - Existing mobile files
outputs:
  - Mobile app files (screens, components, navigation)
  - .claude/project/STATE.md (updated)
tags:
  - building
  - mobile
  - react-native
  - swift
  - swiftui
  - kotlin
  - compose
  - ios
  - android
  - native
---

# Skill: Mobile Development

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0007 |
| **Version** | 2.0 |
| **Owner** | builder |
| **Inputs** | Task description, DECISIONS.md, existing mobile files |
| **Outputs** | Mobile app files, STATE.md updated |
| **Triggers** | `MOBILE_TASK_READY` |

---

## Purpose

Build mobile apps for iOS, Android, or both. Three supported platforms: React Native + Expo (cross-platform, default), Swift/SwiftUI (native iOS), Kotlin/Jetpack Compose (native Android). Default: React Native + Expo unless DECISIONS.md specifies otherwise.

---

## Stack Defaults

### React Native + Expo (Cross-Platform)

| Concern | Default | Why |
|---------|---------|-----|
| Framework | React Native + Expo (managed) | Cross-platform, beginner-friendly |
| Navigation | React Navigation | Most widely used |
| State | useState/useContext (simple), Zustand (complex) | Minimal boilerplate |
| Styling | StyleSheet API | No extra dependencies |

### Swift/SwiftUI (Native iOS)

| Concern | Default | Why |
|---------|---------|-----|
| UI Framework | SwiftUI | Apple's modern declarative framework |
| Architecture | MVVM + @Observable | Replaces ObservableObject, granular view updates |
| Navigation | NavigationStack + NavigationPath | Type-safe, supports deep linking (iOS 16+) |
| Dependency Management | Swift Package Manager (SPM) | First-party, built into Xcode |
| Data Persistence | SwiftData (simple), Core Data (complex) | SwiftData is Swift-native; Core Data for heavy relational models |
| Networking | URLSession + async/await | First-party, zero dependencies |
| Min Target | iOS 17 | Enables @Observable, SwiftData, modern SwiftUI |
| Concurrency | async/await + actors | Replaces GCD; Swift 6.2 defaults to @MainActor |
| DI | Protocol-based + @Environment | No third-party framework needed |
| Image Loading | AsyncImage | Built-in, no third-party needed |

### Kotlin/Jetpack Compose (Native Android)

| Concern | Default | Why |
|---------|---------|-----|
| UI Framework | Jetpack Compose | Google's modern declarative toolkit |
| Architecture | MVVM + StateFlow + UDF | Lifecycle-aware, Google-recommended |
| Navigation | Navigation Compose 2.8+ (type-safe routes) | Official, @Serializable data class routes |
| DI | Hilt | Official Android DI, minimal boilerplate |
| Data Persistence | Room (relational), DataStore (preferences) | Room for structured data, DataStore replaces SharedPreferences |
| Networking | Retrofit + OkHttp + kotlinx.serialization | Industry standard, coroutine support |
| Build System | Gradle + Kotlin DSL + Version Catalogs | Centralized dependency management |
| Min Target | API 26 (Android 8.0) | Covers 95%+ devices, notification channels, java.time |
| Concurrency | Kotlin Coroutines + Flow | Structured concurrency |
| Image Loading | Coil | Kotlin-first, Compose-native |

---

## Procedure

1. **Determine platform and style.** Read DECISIONS.md for platform choice. If none exists, ask the user:
   - **Platform:** "React Native (cross-platform), Swift (iOS only), or Kotlin (Android only)?"
   - **Architecture pattern:** "MVVM (default — works for most apps), MVI (best for complex state like chat or multi-step forms), or Clean Architecture (enterprise, strict layering)?"
   - **Data persistence:** iOS: "SwiftData (default, modern) or Core Data (complex relational models)?" / Android: "Room (default, structured data) or DataStore (simple preferences only)?"

   Log all choices to DECISIONS.md. Load the matching Stack Defaults.

2. **Confirm stack choices.** Read DECISIONS.md for any overrides to the stack defaults (e.g., alternative navigation library, different min target). If no decisions exist for a concern, use the default and log it.

3. **Understand the task.** Screen/feature, target platforms, device capabilities needed, data sources.

4. **Build the screen/feature:**
   - **React Native:** Follow platform UI conventions, use `Platform.select()` for platform-specific code, no hardcoded pixel sizes — use Dimensions API or percentages
   - **Swift/SwiftUI:** Use `NavigationStack` for navigation, `@Observable` classes for ViewModels, `@Environment` for DI, `.task {}` for async loading. Follow feature-based folder structure:
     ```
     Features/
       Home/
         HomeView.swift
         HomeViewModel.swift
         Components/
     ```
   - **Kotlin/Compose:** Use `@Composable` functions, `collectAsStateWithLifecycle()` for StateFlow, `@HiltViewModel` for ViewModels, Material 3 components. Follow feature-based structure:
     ```
     feature/home/
       HomeScreen.kt
       HomeViewModel.kt
       components/
     ```
     For medium+ apps, use multi-module: `:feature:home`, `:core:data`, `:core:ui`

5. **Handle all states:** loading, error, empty, populated — every data-dependent component.
   - **React Native:** Conditional rendering with loading/error/empty states
   - **Swift/SwiftUI:** Use `switch` on a state enum (e.g., `enum ViewState { case loading, error(Error), empty, loaded([Item]) }`) with `.overlay` or `Group`
   - **Kotlin/Compose:** Use `sealed interface UiState` with `when` expression in Compose

6. **Device considerations:**
   - **All platforms:** Request permissions only when the user triggers the feature that needs it. Show a rationale screen before the system dialog. Handle denial gracefully with guidance to Settings.
   - **React Native:** SafeAreaView on all screens, KeyboardAvoidingView on forms
   - **Swift/SwiftUI:** Use `.ignoresSafeArea()` deliberately (not by default), handle keyboard with `@FocusState` + `.scrollDismissesKeyboard()`, support Dynamic Type (avoid fixed font sizes)
   - **Kotlin/Compose:** Use `Modifier.systemBarsPadding()` for edge-to-edge, `enableEdgeToEdge()` in Activity, handle configuration changes properly (no state loss on rotation)

7. **Performance:**
   - **React Native:** FlatList for lists >20 items, no anonymous functions in render, explicit image dimensions
   - **Swift/SwiftUI:** `LazyVStack`/`LazyHStack` for long lists, avoid expensive computations in `body`, use `.task` (not `.onAppear`) for async work, use `@State` sparingly
   - **Kotlin/Compose:** `LazyColumn`/`LazyRow` with stable keys, use `remember`/`derivedStateOf` to avoid unnecessary recomposition, use `immutableList` for stable parameters

8. **App Store flags:**
   - **iOS:** Privacy usage descriptions required (NSCameraUsageDescription, NSLocationWhenInUseUsageDescription, etc.), App Transport Security exceptions, export compliance questionnaire, Mac requirement for building/submitting
   - **Android:** Runtime permissions in AndroidManifest.xml, `targetSdk 35` required for new Play Store submissions, data safety form, content rating questionnaire
   - **React Native:** Both sets of flags apply

9. **Update STATE.md.**

---

## Anti-Patterns

Platform-specific mistakes the agent must never generate:

**Swift/iOS — do not use:**
- `ObservableObject` + `@Published` — replaced by `@Observable` (iOS 17+)
- `@StateObject` / `@ObservedObject` — use `@State` with `@Observable` classes
- `@EnvironmentObject` — use `@Environment(Type.self)`
- `DispatchQueue` / GCD — use async/await + actors
- UIKit storyboards or XIBs — use SwiftUI views
- `URLSession` completion handlers — use async/await overloads
- `NavigationView` — use `NavigationStack` (deprecated in iOS 16)
- Combine for UI data binding — use `@Observable` + SwiftUI

**Kotlin/Android — do not use:**
- XML layouts — use Jetpack Compose
- `LiveData` — use `StateFlow` + `collectAsStateWithLifecycle()`
- `kapt` — use KSP (2x+ faster annotation processing)
- `findViewById` — use Compose
- `AsyncTask` or raw threads — use Kotlin Coroutines
- `Dagger` directly — use Hilt (simplified DI)
- Groovy build scripts — use Kotlin DSL (`.gradle.kts`)
- `GlobalScope` — use `viewModelScope` or `lifecycleScope`
- `SharedPreferences` — use DataStore

---

## Constraints

- Never modifies web frontend or backend files
- Never hardcodes API keys or credentials
- Never generates deprecated APIs listed in Anti-Patterns
- Always targets iOS 17+ for Swift projects (unless DECISIONS.md overrides)
- Always targets API 26+ for Kotlin projects (unless DECISIONS.md overrides)
- Always includes accessibility modifiers (`.accessibilityLabel()` on iOS, `contentDescription` on Android, `accessibilityLabel` prop on RN)
- Always flags Mac requirement before iOS build/submission tasks
- **Friction check before marking done:** Run Friction Audit Checklist (`.claude/skills/friction-audit/CHECKLIST.md`). Focus on: tap count for primary action, permission timing, onboarding flow length.

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Platform confirmed from DECISIONS.md (React Native, Swift, or Kotlin)
- [ ] Stack choices confirmed or defaults logged
- [ ] Platform UI conventions and project structure followed
- [ ] All four states handled (loading, error, empty, populated)
- [ ] Device considerations addressed (safe areas, keyboard, permissions)
- [ ] Performance patterns followed (lazy lists per platform)
- [ ] Anti-patterns avoided (no deprecated APIs)
- [ ] Accessibility labels present on interactive elements
- [ ] App Store readiness flags noted
- [ ] STATE.md updated
