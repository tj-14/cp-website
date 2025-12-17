# GitHub Pages Setup Guide

## What Was Changed

The website files have been moved from the `web/` folder to the `docs/` folder to support GitHub Pages deployment from the main branch.

### Changes Made:
- ✅ Moved all HTML files from `web/` to `docs/` (32 files)
- ✅ Moved `style.css` to `docs/`
- ✅ Moved `HTML_IMPROVEMENTS.md` to `docs/`
- ✅ Updated README.md to reflect the new structure
- ✅ Verified all links work correctly

## How to Configure GitHub Pages

To deploy your website using GitHub Pages, follow these steps:

1. Go to your repository on GitHub: `https://github.com/tj-14/cp-website`

2. Click on **Settings** (in the repository menu)

3. In the left sidebar, click on **Pages** (under "Code and automation")

4. Under **Source**, select:
   - **Deploy from a branch**

5. Under **Branch**, select:
   - Branch: **main** (or your default branch)
   - Folder: **/docs**
   - Click **Save**

6. Wait a few minutes for the deployment to complete

7. Your website will be available at: `https://tj-14.github.io/cp-website/`

## Verification

After deployment, you can verify that:
- The homepage loads at `https://tj-14.github.io/cp-website/`
- CSS is applied correctly
- All navigation links work
- All content pages are accessible

## Local Testing

To test the website locally before deployment:

```bash
cd docs
python3 -m http.server 8080
```

Then visit `http://localhost:8080` in your browser.

## Project Structure

The new structure is:

```
cp-website/
├── book/              # Typst source files (original content)
│   ├── content/      # Content .typ files
│   └── comp_book.typ # Main file
├── docs/              # Website HTML (GitHub Pages)
│   ├── index.html    # Homepage
│   ├── style.css     # Global styles
│   └── *.html        # Content pages
├── GEMINI.md         # Guidelines
└── README.md         # This file
```

## Notes

- The `docs/` folder is a standard convention for GitHub Pages
- All internal links in HTML files use relative paths and will work correctly
- No changes to HTML content were needed - only the folder structure changed
- The `book/` folder contains the original Typst source materials and is separate from the website
