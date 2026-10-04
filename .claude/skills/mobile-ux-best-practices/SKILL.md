---
name: mobile-ux-best-practices
description: Mobile UX design rules and audit criteria covering thumb zone design, touch targets, navigation, form optimization, offline state handling, performance benchmarks, accessibility, and intentional gestures. Use when designing, auditing, reviewing, or building mobile applications or wireframes.
---

# Mobile UX Best Practices

A comprehensive framework and checklist for reviewing, auditing, and designing mobile user interfaces across iOS and Android platforms.

## When to Use

- Designing mobile app wireframes, mockups, or UI layouts.
- Auditing mobile app user experience (UX) and interface (UI) designs.
- Setting technical or design standards for touch targets, loading performance, or navigation.
- Evaluating mobile forms, offline behaviors, micro-interactions, or gesture controls.

## Core Best Practices

### 1. Design for the Thumb Zone
- **Reachability Focus**: Over 75% of mobile interactions are thumb-driven. Place key interactive controls in the bottom third of the screen.
- **Action Placement**: Primary actions (e.g., Submit, Next, Checkout) belong in the natural thumb reach zone.
- **Destructive Actions**: Place destructive actions (e.g., Delete, Cancel) in harder-to-reach areas (such as top corners) to avoid accidental taps.
- **Bottom Sheets**: Prefer bottom sheets over top-positioned modal dialogs for contextual options and actions.

### 2. Respect Minimum Touch Target Sizes
- **Standard Sizing**: Maintain minimum touch target sizes across platforms:
  - **Apple iOS**: 44 x 44 pt minimum
  - **Google Android**: 48 x 48 dp minimum
  - **Web/WCAG**: 44 x 44 CSS pixels minimum
- **Spacing & Padding**: Provide adequate spacing between adjacent interactive elements (buttons, links, checkboxes, close buttons) to eliminate accidental misclicks.

### 3. Simplify Navigation
- **Item Limit**: Cap primary navigation at a maximum of 5 items in a visible bottom tab bar.
- **Labels + Icons**: Always pair standard icons with clear text labels to avoid ambiguity.
- **Platform Back Conventions**: Respect native back patterns (iOS swipe-from-edge, Android system back button/gesture). Never override standard platform navigation.
- **Location Awareness**: Highlight active states clearly, present descriptive screen titles, and maintain breadcrumbs or clean hierarchy indicators.

### 4. Optimize Forms for Mobile Input
- **Input Types**: Set specific input types (`email`, `tel`, `numeric`, `url`) to automatically trigger the optimal soft keyboard.
- **Field Labels**: Position labels above inputs rather than relying solely on floating placeholder text that disappears upon focus.
- **Validation**: Implement real-time inline validation with actionable guidance rather than validating only on submission.
- **Autofill & Pre-fill**: Enable native autofill and leverage device data to minimize manual typing.

### 5. Design for Offline and Poor Connectivity
- **Caching**: Locally cache critical content so core features remain accessible without network access.
- **Queueing Actions**: Queue user actions locally when offline and sync automatically when connection returns.
- **Graceful Failure**: Display calm, informative offline indicators instead of blank screens or raw technical error codes.

### 6. Performance Benchmarks
- **App Launch Time**: Cold launch under 2 seconds (poor if > 4 seconds).
- **Screen Transitions**: Under 300 ms (poor if > 1 second).
- **Touch Response**: Visual feedback under 100 ms (poor if > 300 ms).
- **API Content Loading**: Under 1 second (poor if > 3 seconds).
- **Frame Rate**: Maintain steady 60 fps without frame drops.
- **Perceived Speed**: Utilize skeleton screens and optimistic UI updates to reduce perceived latency.

### 7. Build for Accessibility from Day One
- **Color Contrast**: Minimum 4.5:1 ratio for body text; 3:1 for large text.
- **Dynamic Text**: Support system-level font scaling without breaking layout containers.
- **Screen Readers**: Provide clear semantic labels for buttons, inputs, and state changes.
- **Multi-Modal Cues**: Avoid relying on color alone to communicate status or validation states.

### 8. Use Gestures Intentionally
- **Supplementary Gestures**: Custom gestures (e.g., swipe-to-delete) must supplement visible buttons, never replace them entirely.
- **Platform Consistency**: Maintain native platform gestures without introducing non-standard swipe behaviors.

## Audit Checklist & Common Pitfalls

- [ ] Are key interactive controls located in the natural bottom-third thumb zone?
- [ ] Are all touch targets at least 44x44 pt / 48x48 dp with adequate spacing?
- [ ] Is the primary navigation visible with 5 or fewer labeled icons?
- [ ] Are input labels placed above fields rather than relying on placeholder text?
- [ ] Does the application support graceful offline handling and local data queuing?
- [ ] Are screen transitions and touch feedback within target performance thresholds (<300ms / <100ms)?
- [ ] Is dark mode supported to reduce eye strain and preserve OLED battery life?
- [ ] Are micro-interactions used purposefully to confirm user actions rather than merely for decoration?
