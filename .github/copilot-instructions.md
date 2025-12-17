# Copilot Instructions for CP Website

## Project Overview
This is an educational website for Thai high school students preparing for Computer Olympiad camps. The content is based on 3 years of teaching experience at POSN (สอวน.) camps.

**Goal**: Turn incomplete book draft content into an interactive, accessible educational website.

**Target Audience**: Thai high school students interested in competitive programming.

## Tech Stack & Architecture
- **HTML5**: Semantic markup for content structure
- **CSS3**: Minimal, maintainable styling
- **No JavaScript frameworks**: Keep it simple and "boring" for low maintenance
- **Deployment**: GitHub Pages
- **No build systems**: Direct HTML/CSS files, no compilation needed

### Local Development
```bash
cd web
python3 -m http.server 8080
```

## Design Principles

### Inspiration
- **Primary reference**: https://cp-algorithms.com/index.html (clean, minimal, content-focused)
- **Secondary reference**: https://usaco.guide (but keep simpler and less featureful)

### Key Principles
- **Minimal**: No unnecessary features or complexity
- **Readable**: Proper typography and spacing for long-form educational content
- **Clear Navigation**: Easy movement between topics and sections
- **Responsive**: Works well on both mobile and desktop
- **Accessible**: Semantic HTML, proper contrast, readable fonts

## Content Guidelines

### Language Usage
- **Primary language**: Thai (ภาษาไทย) for maximum accessibility to target audience
- **English terms**: Introduce English terminology that's important for competitive programming career
  - Example: Use "Dynamic programming" instead of "กำหนดการพลวัต"
  - Example: Keep technical terms like "Big O notation", "heap", "graph" in English
- **Consistency**: Once a term is introduced, use it consistently throughout

### Content Structure
Content is organized by POSN camp levels:
- **Camp 1** (ค่าย 1): C/C++ programming basics
- **Camp 2** (ค่าย 2): Data structures and algorithms
- **Advanced levels**: Advanced techniques and problem-solving

## Key Resources to Promote

Always reference and promote these resources when relevant:

### Practice Platforms
1. https://programming.in.th/ - Primary Thai grader platform
2. https://cses.fi/problemset/ - CSES problem set

### Recommended Books
1. https://cses.fi/book/book.pdf - Competitive Programmer's Handbook
2. https://www.csc.kth.se/~jsannemo/slask/main.pdf - Principles of Algorithmic Problem Solving

## Working with This Codebase

### When Making Changes
1. **Focus on HTML quality**: Use semantic HTML5 elements properly
2. **Ensure consistent navigation**: All pages should have similar navigation structure
3. **Keep styling minimal**: Add only necessary CSS, avoid over-styling
4. **Test responsiveness**: Check that changes work on mobile and desktop
5. **Maintain accessibility**: Use proper heading hierarchy, alt text, ARIA labels when needed

### File Structure
```
cp-website/
├── book/              # Typst source files (original draft)
│   ├── content/      # .typ content files
│   └── comp_book.typ # Main file
├── web/              # HTML website
│   ├── index.html    # Homepage
│   ├── style.css     # Global styles
│   └── *.html        # Content pages
├── GEMINI.md         # Project requirements
└── README.md
```

### HTML Naming Convention
Files follow a numbering pattern:
- `0000-0999`: Introduction/starter content
- `1000-1999`: Camp 1 content (basics)
- `2000-2999`: Camp 2 content (data structures)
- `3000-3999`: Advanced algorithms
- `4000+`: Specialized topics
- `9000+`: Resources and supplementary content

### Code Style Preferences
- **HTML**: Use semantic elements (`<article>`, `<section>`, `<nav>`, `<header>`, etc.)
- **CSS**: Keep selectors simple, prefer classes over complex selectors
- **Indentation**: 2 spaces for HTML/CSS
- **Comments**: Add comments in Thai for content explanations, English for technical notes

### What NOT to Do
- ❌ Don't add JavaScript frameworks (React, Vue, etc.)
- ❌ Don't introduce build tools (webpack, vite, etc.)
- ❌ Don't add complex dependencies
- ❌ Don't over-engineer solutions
- ❌ Don't change the minimalist design philosophy
- ❌ Don't remove or change existing working navigation

### What TO Do
- ✅ Improve semantic HTML structure
- ✅ Enhance accessibility
- ✅ Fix inconsistencies in navigation between pages
- ✅ Improve readability and typography
- ✅ Keep code simple and maintainable
- ✅ Add proper meta tags for SEO
- ✅ Ensure consistent styling across pages

## Testing Changes
Since this is a static site:
1. Run local server: `cd web && python3 -m http.server 8080`
2. Open `http://localhost:8080` in browser
3. Navigate between pages to check consistency
4. Test on different screen sizes (mobile, tablet, desktop)
5. Validate HTML if making structural changes

## Common Tasks

### Adding a New Content Page
1. Create HTML file in `web/` directory with appropriate number prefix
2. Follow existing page structure (navigation, header, content, footer)
3. Add link to navigation menu in all existing pages (or update shared navigation if applicable)
4. Use semantic HTML elements
5. Keep consistent styling with other pages

### Improving Navigation
1. Check all pages have consistent navigation structure
2. Ensure current page is highlighted in navigation
3. Add breadcrumbs if it improves usability
4. Keep navigation simple and uncluttered

### Styling Updates
1. Make changes in `style.css` when possible (global changes)
2. Use inline styles only for page-specific styling (minimize this)
3. Ensure changes maintain responsive design
4. Test with different viewport sizes

## Accessibility Checklist
- [ ] Proper heading hierarchy (h1 → h2 → h3, no skipping)
- [ ] Alt text for all images
- [ ] Sufficient color contrast (WCAG AA minimum)
- [ ] Keyboard navigable
- [ ] Semantic HTML elements used appropriately
- [ ] Links have descriptive text (avoid "click here")
- [ ] Forms have proper labels (if any)

## Remember
This is an educational resource for students. Keep it:
- **Simple**: Easy to understand and navigate
- **Fast**: No heavy dependencies or complex loading
- **Accessible**: Works for everyone, including students with slower connections
- **Maintainable**: Future contributors should easily understand the code
