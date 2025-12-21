# Minimal Zola Site

This is a minimal "Hello World" static website built with Zola and deployed to GitHub Pages.

## Local Development

Build and serve the site locally:

```bash
cd website
zola serve
```

Then visit http://127.0.0.1:1111

## Deployment

The site is automatically deployed to GitHub Pages when you push to the `main` branch.

**First-time setup:**

1. Go to your repository settings on GitHub
2. Navigate to Settings → Pages
3. Under "Build and deployment":
   - Source: Select "GitHub Actions"
4. Push your changes to trigger the deployment

The site will be available at: https://douzebis.github.io/selfhost

## Project Structure

```
website/
├── config.toml          # Site configuration
├── content/
│   └── _index.md       # Homepage content
├── templates/
│   └── index.html      # Homepage template
└── static/             # Static assets (images, CSS, etc.)
```
