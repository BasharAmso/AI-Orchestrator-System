# Friction Audit Checklist

> Referenced by PRD Writing, Frontend Dev, Code Review, UAT, Growth, and Mobile Dev skills.
> Use when evaluating anything user-facing.

## Core Questions (Always Ask)

1. Can a first-time user find the primary action in under 5 seconds?
2. Is the happy path under 5 steps?
3. Are there any steps that could be removed or combined?
4. Do error messages tell the user what happened AND what to do next?
5. Are permissions/signups deferred until actually needed?

## Interaction Friction (UI/Frontend)

- [ ] No unnecessary form fields (every field earns its place)
- [ ] Smart defaults pre-filled where possible
- [ ] No re-entering information the system already has
- [ ] Loading states are clear (user knows something is happening)
- [ ] Empty states guide the user (not blank screens)
- [ ] Primary CTA is obvious without scrolling

## Onboarding Friction (New Users)

- [ ] First meaningful action takes under 60 seconds
- [ ] Can skip optional steps and come back later
- [ ] Progress indicator on multi-step flows
- [ ] Shows value before asking for commitment (signup, payment, permissions)

## Cognitive Friction (Clarity)

- [ ] One primary action per screen/page
- [ ] Labels use plain language (not jargon)
- [ ] Navigation is predictable (no surprises)
- [ ] Undo is available for destructive actions
