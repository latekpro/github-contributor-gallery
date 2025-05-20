require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get('/api/contributors/:owner/:repo', async (req, res) => {
  try {
    const { owner, repo } = req.params;
    
    // GitHub API URL for fetching contributors
    const apiUrl = `https://api.github.com/repos/${owner}/${repo}/contributors`;
    
    // Optional: Add GitHub token for higher rate limits
    const headers = process.env.GITHUB_TOKEN 
      ? { Authorization: `token ${process.env.GITHUB_TOKEN}` }
      : {};
    
    const response = await axios.get(apiUrl, { headers });
    
    // Return contributors data
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching contributors:', error.message);
    
    // Handle specific GitHub API errors
    if (error.response) {
      const { status, data } = error.response;
      if (status === 404) {
        return res.status(404).json({ error: 'Repository not found' });
      } else if (status === 403 && data.message.includes('rate limit')) {
        return res.status(403).json({ error: 'GitHub API rate limit exceeded' });
      }
      return res.status(status).json({ error: data.message || 'Error from GitHub API' });
    }
    
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
