# Design Quality Checklist

> Referenced by Frontend Dev, Growth, Game Dev, and Mobile Dev skills.
> Use when building or reviewing any user-facing UI.

## Typography Rhythm

- [ ] Font pairing is deliberate (serif + sans-serif OR single family with weight contrast)
- [ ] Heading hierarchy has at least 3 distinct sizes with noticeable jumps
- [ ] Body text line height: 1.5-1.7; Headings: 1.1-1.3
- [ ] Uppercase labels use positive letter spacing (0.05-0.15em)
- [ ] At least one "wow" text moment (oversized, italic, or distinctly styled)

## Color & Contrast

- [ ] Limited palette: 1 primary, 1 accent, 2-3 neutrals (max 5 colors)
- [ ] Text/background contrast meets WCAG 2.1 AA (4.5:1 normal, 3:1 large)
- [ ] At least one inverted section (dark bg/light text) for visual variety
- [ ] Accent color used sparingly (CTAs, highlights, decorative elements only)

## Scroll Animations

- [ ] Content sections animate in on scroll (fade-up, slide-in, or scale)
- [ ] Lists, grids, and card groups stagger entrance (50-100ms delay)
- [ ] Parallax used sparingly (max one element per page)
- [ ] All animations wrapped in `prefers-reduced-motion` check

## Micro-Interactions

- [ ] Buttons have visible hover state beyond color change (scale, shadow lift, or fill)
- [ ] Gallery/portfolio images respond to hover (zoom, overlay, or caption reveal)
- [ ] Interactive elements have visible focus rings matching the design language
- [ ] All state changes use transitions (min `duration-200`), no instant snaps
- [ ] Clickable non-link elements use `cursor-pointer`

## Visual Depth

- [ ] At least one section has overlapping elements (card bleeding over boundary, text over image)
- [ ] Cards and elevated elements have subtle shadows (`shadow-sm` to `shadow-lg`)
- [ ] Subtle background gradients separate sections (no hard color blocks)
- [ ] Generous whitespace between sections (py-16 to py-24)

## Component Library

- [ ] Uses existing component library if project has one (shadcn/ui, Radix, etc.)
- [ ] Customization through theme/token layer, not style overrides
- [ ] New library choices logged to DECISIONS.md

## Anti-Patterns (Flag and Fix)

These are common mistakes in AI-generated UIs. Actively scan for them.

| Anti-Pattern | What to Check |
|-------------|---------------|
| **Rainbow syndrome** | More than 5 distinct hues on one page |
| **Shadow soup** | Multiple shadow intensities with no consistent elevation system |
| **Animation carnival** | More than 3 different animation types on one page |
| **Contrast theater** | Decorative dark sections that make text unreadable |
| **Font buffet** | More than 2 font families loaded |
| **Placeholder blindness** | Lorem ipsum or "Coming soon" left in shipped pages |
| **Mobile afterthought** | Desktop layout with only `hidden md:block` responsive handling |
| **Accessibility bypass** | Missing alt text, focus indicators, or reduced-motion respect |
