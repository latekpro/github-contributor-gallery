# GitHub Contributor Gallery

A two-tier web application that displays contributors to GitHub repositories in a visual gallery.

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

## License

MIT
