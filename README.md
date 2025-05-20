# GitHub Contributor Gallery

A two-tier web application that displays contributors to GitHub repositories in a visual gallery.

[![Deploy Infrastructure](https://github.com/yourusername/github-contributor-gallery-vd/actions/workflows/deploy-infrastructure.yml/badge.svg)](https://github.com/yourusername/github-contributor-gallery-vd/actions/workflows/deploy-infrastructure.yml)
[![Deploy Backend](https://github.com/yourusername/github-contributor-gallery-vd/actions/workflows/deploy-backend.yml/badge.svg)](https://github.com/yourusername/github-contributor-gallery-vd/actions/workflows/deploy-backend.yml)
[![Deploy Frontend](https://github.com/yourusername/github-contributor-gallery-vd/actions/workflows/deploy-frontend.yml/badge.svg)](https://github.com/yourusername/github-contributor-gallery-vd/actions/workflows/deploy-frontend.yml)
[![Full Deployment](https://github.com/yourusername/github-contributor-gallery-vd/actions/workflows/full-deployment.yml/badge.svg)](https://github.com/yourusername/github-contributor-gallery-vd/actions/workflows/full-deployment.yml)

> **Note:** GitHub Actions workflows are located in the `.github/workflows` directory at the **repository root**, not inside the project directory.

## Features

- Enter a GitHub username/organization and repository name
- View all contributors with their avatars and contribution counts
- Responsive design for all screen sizes
- Real-time API integration with GitHub

## Tech Stack

- **Frontend**: React, Vite, Axios
- **Backend**: Node.js, Express
- **APIs**: GitHub API

## Installation

### Prerequisites

- Node.js (v14+)
- npm or yarn

### Backend Setup

```bash
# Navigate to the backend directory
cd backend

# Install dependencies
npm install

# Start the server
npm start
```

The backend server will run on http://localhost:5000.

### Frontend Setup

```bash
# Navigate to the frontend directory
cd frontend

# Install dependencies
npm install

# Start the development server
npm run dev
```

The frontend application will run on http://localhost:3000.

## Usage

1. Open the application in your browser at http://localhost:3000
2. Enter a GitHub username/organization (e.g., "facebook")
3. Enter a repository name (e.g., "react")
4. Click "Search Contributors" to view the gallery

## Environment Variables

### Backend

Create a `.env` file in the backend directory with the following variables:

```
PORT=5000
GITHUB_TOKEN=your_github_token_here (optional)
```

## Azure Deployment

This application can be deployed to Azure using GitHub Actions. For detailed instructions, see [Azure Deployment Guide](AZURE-DEPLOYMENT.md).

### Azure Resources

The deployment creates the following Azure resources:
- App Service Plan (Basic B1 tier)
- 2 App Services (for Frontend and Backend)
- Application Insights
- Log Analytics Workspace
- User Assigned Managed Identity

### GitHub Actions Workflows

There are four GitHub Actions workflows:
- **Deploy Infrastructure** - Creates Azure resources
- **Deploy Backend** - Deploys the backend Node.js application
- **Deploy Frontend** - Builds and deploys the frontend React application
- **Full Deployment** - Runs all the above workflows in sequence in a single flow

All workflows are manually triggered and can be run from the GitHub Actions tab. You can either run them individually in sequence or use the Full Deployment workflow to deploy everything at once.

## License

MIT
