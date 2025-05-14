# Git Setup for Smart Home Platform

This project is configured with Git for version control. Here's how to work with it:

## Repository Structure

The repository is hosted on GitHub at: https://github.com/AKlifewire/akorede

## Branch Strategy

- `main`: Production-ready code
- Feature branches: Create new branches for features using `git checkout -b feature/your-feature-name`

## Workflow

1. **Clone the repository**:
   ```bash
   git clone https://github.com/AKlifewire/akorede.git
   cd akorede
   ```

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/new-feature
   ```

3. **Make changes and commit**:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

4. **Push changes**:
   ```bash
   git push origin feature/new-feature
   ```

5. **Create a Pull Request**:
   - Go to GitHub
   - Navigate to your branch
   - Click "New Pull Request"
   - Follow the PR template

## GitHub Actions Integration

When you push to the `main` branch or create a PR, GitHub Actions will:

1. Build and test your code
2. Deploy to AWS (if on main branch)
3. Run infrastructure tests

## Git Configuration

The repository includes:
- `.gitignore`: Excludes build artifacts, dependencies, etc.
- `.gitattributes`: Handles line endings properly
- `.github/CODEOWNERS`: Defines code ownership
- `.github/pull_request_template.md`: Template for PRs

## Best Practices

1. Write clear commit messages
2. Keep commits focused on a single change
3. Pull and rebase before pushing
4. Use PR reviews for code quality
5. Tag releases with semantic versioning