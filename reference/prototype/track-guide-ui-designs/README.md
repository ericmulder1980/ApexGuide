# CODING AGENTS: READ THIS FIRST

This is a **handoff bundle** from Claude Design (claude.ai/design).

A user mocked up designs in HTML/CSS/JS using an AI design tool, then exported this bundle so a coding agent can implement the designs for real.

## What you should do — IMPORTANT

**Read `track-guide-ui-designs/project/ApexGuide Screens.dc.html` in full.** The user had this file open when they triggered the handoff, so it's almost certainly the primary design they want built. Read it top to bottom — don't skim. Then **follow its imports**: open every file it pulls in (shared components, CSS, scripts) so you understand how the pieces fit together before you start implementing.

**If anything is ambiguous, ask the user to confirm before you start implementing.** It's much cheaper to clarify scope up front than to build the wrong thing.

## About the design files

The design medium is **HTML/CSS/JS** — these are prototypes, not production code. Your job is to **recreate them pixel-perfectly** in whatever technology makes sense for the target codebase (React, Vue, native, whatever fits). Match the visual output; don't copy the prototype's internal structure unless it happens to fit.

**Don't render these files in a browser or take screenshots unless the user asks you to.** Everything you need — dimensions, colors, layout rules — is spelled out in the source. Read the HTML and CSS directly; a screenshot won't tell you anything they don't.

## Bundle contents

- `track-guide-ui-designs/README.md` — this file
- `track-guide-ui-designs/project/` — the `Track Guide UI designs` project files (HTML prototypes, assets, components)

## Logo designs
`./Logo options design.png` contains different variants of the logo for light and dark backgrounds.

### Row 1 — Primary brand assets

1.  **logo\_full.svg — Full Logo**

    *   The complete ApexGuide brand lockup.

    *   Contains the stylized **A** racing symbol above/alongside the **ApexGuide** wordmark.

    *   “Apex” is dark navy/black; “Guide” is racing red.

    *   Intended for primary branding, website headers, splash screens, and marketing materials.

2.  **app\_icon.svg — App Icon**

    *   The complete racing-line **A symbol enclosed in a rounded-square dark background**.

    *   Optimized for use as the mobile application icon.

    *   Contains the white/dark A, sweeping racing line, and red/white kerb detail.

3.  **mark.svg — Standalone Mark**

    *   The **ApexGuide symbol only**, without the wordmark or app background.

    *   Consists of the stylized A combined with the sweeping racing line and red/white kerb.

    *   Useful as a brand mark, watermark, favicon, or decorative graphic.

4.  **mark\_app\_icon.svg — Standalone Mark in App Treatment**

    *   The standalone ApexGuide mark placed inside the dark rounded-square app treatment.Essentially the iconographic version of the brand without the ApexGuide wordmark.

    *   Useful where the symbol needs to be immediately recognizable as an app/brand.


### Row 2 — Brand building blocks

1.  **colors.svg — Brand Color Palette**

    *   Shows the core ApexGuide colors:

        *   **Dark navy/near-black** — primary brand color

        *   **Racing red** — accent/performance color

        *   **White** — primary contrast color

        *   **Medium gray** — supporting neutral

        *   **Light gray** — secondary/background neutral

    *   This establishes the basic visual language for the app and marketing materials.

2.  **racing\_line.svg — Racing Line Element**

    *   A standalone sweeping racing-line graphic.

    *   Combines the dark racing line with the red/white kerb treatment.

    *   Can be used independently as a decorative or UI element, background graphic, section divider, or animation element.

3.  **A\_shape.svg — ApexGuide A Symbol**

    *   The geometric **A** extracted from the main logo.

    *   Represents the primary structural element of the ApexGuide identity.

    *   Can be used independently when a very minimal brand treatment is required.

4.  **kerb\_stripe.svg — Kerb Accent**

    *   The red-and-white striped kerb element extracted from the racing-line graphic.

    *   Represents the motorsport/karting connection.

    *   Could be particularly useful as a subtle recurring graphic element throughout the app UI.


### Row 3 — Secondary lockups and raster asset

1.  **wordmark.svg — Wordmark**

    *   **ApexGuide** text without the standalone A/racing symbol.

    *   “Apex” uses the dark primary color while “Guide” uses racing red.

    *   Useful when the symbol is already present elsewhere or when a horizontal text treatment is preferable.

2.  **horizontal\_lockup.svg — Horizontal Brand Lockup**


*   Combines the **ApexGuide symbol + wordmark** in a horizontal configuration.

*   A vertical divider separates the symbol from the name.

*   Designed for headers, websites, social banners, presentations, merchandise, and other wide-format applications.


1.  **app\_icon.png — Raster App Icon**


*   A **1024 × 1024 PNG** version of the app icon.

*   Intended for platforms or workflows that require a raster image rather than SVG.

*   This is the appropriate starting resolution for producing the various platform-specific app-icon sizes.
