---
id: SKL-0007
name: Mobile Development
description: |
  Build mobile app screens, navigation, and platform-specific features. Use
  this skill when a mobile task is ready for implementation, including React
  Native, Expo, and native platform code.
version: 1.0
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
---

# Skill: Mobile Development

## Metadata

| Field | Value |
|-------|-------|
| **Skill ID** | SKL-0007 |
| **Version** | 1.0 |
| **Owner** | builder |
| **Inputs** | Task description, DECISIONS.md, existing mobile files |
| **Outputs** | Mobile app files, STATE.md updated |
| **Triggers** | `MOBILE_TASK_READY` |

---

## Purpose

Build cross-platform mobile apps for iOS and Android. Default stack: React Native + Expo. Alternative: Flutter (log in DECISIONS.md if chosen).

---

## Stack Defaults

| Concern | Default | Why |
|---------|---------|-----|
| Framework | React Native + Expo (managed) | Cross-platform, beginner-friendly |
| Navigation | React Navigation | Most widely used |
| State | useState/useContext (simple), Zustand (complex) | Minimal boilerplate |
| Styling | StyleSheet API | No extra dependencies |

---

## Procedure

1. **Read DECISIONS.md** — confirm framework, navigation, state management.
2. **Understand the task** — screen/feature, target platforms, device capabilities needed.
3. **Build the screen/feature:**
   - Follow platform UI conventions (iOS: back gestures, bottom tabs; Android: back button, material design)
   - Use `Platform.select()` for platform-specific code
   - No hardcoded pixel sizes — use Dimensions API or percentages
4. **Handle all states:** loading (spinner/skeleton), error (message + retry), empty (helpful guidance), populated.
5. **Device considerations:**
   - SafeAreaView on all screens
   - KeyboardAvoidingView on all forms
   - Request device permissions only when needed, handle denial gracefully
6. **Performance:** FlatList for lists >20 items, no anonymous functions in render, explicit image dimensions.
7. **App Store flags:** Note privacy usage descriptions needed, flag Mac requirement for iOS submission.
8. **Update STATE.md.**

---

## Constraints

- Never modifies web frontend or backend files
- Never hardcodes API keys or credentials
- Always uses SafeAreaView
- Always flags Mac requirement before iOS submission tasks

---

## Primary Agent

builder

---

## Definition of Done

- [ ] Stack confirmed from DECISIONS.md
- [ ] Platform UI conventions followed
- [ ] All four states handled
- [ ] SafeAreaView and KeyboardAvoidingView used
- [ ] No hardcoded pixel sizes
- [ ] FlatList for long lists
- [ ] App Store readiness flags noted
- [ ] STATE.md updated
