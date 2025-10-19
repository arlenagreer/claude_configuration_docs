# Glassmorphic Design Style Guide

## Overview
A modern design approach featuring translucent elements with blur effects, creating a glass-like appearance. This style emphasizes depth, layering, and subtle transparency effects over vibrant animated backgrounds.

## Color Palette
- **Background**: Animated gradient (#667eea → #764ba2 → #f093fb → #4facfe)
- **Glass Elements**: Semi-transparent white overlays (rgba(255, 255, 255, 0.1-0.2))
- **Text**: High-contrast white with varying opacity (0.7-0.95)
- **Accents**: Soft glows and colored borders with transparency

## Typography
- **Font Family**: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif
- **Weight**: Light to medium (300-600)
- **Text Color**: White with transparency levels for hierarchy
- **Letter Spacing**: Subtle spacing for elegance (-0.5px to 0.5px)

## Glass Effects
### Backdrop Filter
- **Primary Blur**: 20px for main containers
- **Secondary Blur**: 10px for form elements
- **Support**: -webkit-backdrop-filter for browser compatibility

### Transparency Layers
- **Main Container**: rgba(255, 255, 255, 0.1)
- **Form Elements**: rgba(255, 255, 255, 0.08)
- **Interactive States**: rgba(255, 255, 255, 0.12-0.2)

## Layout & Structure
- **Container**: Centered, max-width 800px with perspective transforms
- **Borders**: Thin (1px) semi-transparent white borders
- **Border Radius**: Generous (12-20px) for soft, organic feel
- **Shadows**: Multiple layered shadows for depth

## Interactive Elements
### Form Controls
- **Input Styling**: Translucent backgrounds with subtle borders
- **Focus States**: Increased opacity and enhanced glow effects
- **Placeholders**: Semi-transparent text for subtle guidance

### Buttons
- **Background**: Linear gradient with transparency
- **Hover Effects**: Transform translateY(-2px) with enhanced shadows
- **Animation**: Shimmer effects on hover with pseudo-elements

### Priority Selectors
- **Radio Buttons**: Custom styling with color-coded selections
- **Visual Feedback**: Glowing borders matching priority levels
- **Colors**: Green (low), Yellow (medium), Red (high) with transparency

## Animated Background
### Gradient Animation
- **Movement**: 15-second infinite ease animation
- **Positions**: 0% → 100% → 0% background position shifts
- **Colors**: Smooth transitions between 4+ gradient stops

### Floating Orbs
- **Positioning**: Fixed positioned elements behind content
- **Blur Effect**: Heavy blur (40px) for depth
- **Animation**: 20-second floating movements with scale variations
- **Opacity**: 0.7-0.8 for subtle presence

## Visual Hierarchy
- **Headers**: Large text with text-shadow for definition
- **Form Labels**: Uppercase with letter spacing for clarity
- **Content Areas**: Layered transparency levels
- **Interactive Elements**: Hover states with subtle transformations

## Depth & Layering
- **Z-index Management**: Careful stacking of transparent elements
- **Shadow Layers**: Multiple box-shadows for realistic depth
- **Perspective**: 3D transforms for enhanced dimensionality
- **Blur Variations**: Different blur levels for depth perception

## Responsive Design
- **Mobile**: Simplified padding and single-column layouts
- **Tablet**: Maintained glass effects with adjusted proportions
- **Desktop**: Full decorative elements and complex layering

## Key Characteristics
- Emphasis on transparency and layered depth
- Soft, elegant interactions with subtle feedback
- Modern, premium aesthetic with sophisticated blur effects
- Careful balance between transparency and readability
- Smooth animations that enhance rather than distract