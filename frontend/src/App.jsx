import { useState } from 'react';
import axios from 'axios';
import ContributorGallery from './components/ContributorGallery';
import SearchForm from './components/SearchForm';
import Loading from './components/Loading';

const API_URL = 'http://localhost:5000/api';

function App() {
  const [contributors, setContributors] = useState([]);
  const [repoInfo, setRepoInfo] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const fetchContributors = async (owner, repo) => {
    // Reset states
    setContributors([]);
    setRepoInfo(null);
    setError('');
    setLoading(true);

    try {
      const response = await axios.get(`${API_URL}/contributors/${owner}/${repo}`);
      
      if (response.data && response.data.length > 0) {
        setContributors(response.data);
        setRepoInfo({ owner, repo });
      } else {
        setError('No contributors found for this repository');
      }
    } catch (err) {
      console.error('Error fetching contributors:', err);
      
      if (err.response) {
        // Server returned an error
        const { status, data } = err.response;
        
        if (status === 404) {
          setError('Repository not found. Please check the owner and repo name.');
        } else if (status === 403 && data.error?.includes('rate limit')) {
          setError('GitHub API rate limit exceeded. Please try again later.');
        } else {
          setError(data.error || 'Failed to fetch contributors');
        }
      } else if (err.request) {
        // Request made but no response received
        setError('No response from server. Please check your connection.');
      } else {
        // Something else happened
        setError('An error occurred. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };
  return (
    <>
      <header>
        <h1>GitHub Contributor Gallery</h1>
        <p>View all contributors to a GitHub repository</p>
        <div className="subtitle">Denis rocks!</div>
      </header>
      <div className="container">
        <SearchForm onSearch={fetchContributors} />
        
        {error && <div className="error">{error}</div>}
          {loading ? (
          <Loading />
        ) : repoInfo && (
          <>
            <h2>Contributors to {repoInfo.owner}/{repoInfo.repo}</h2>
            <ContributorGallery contributors={contributors} />
          </>
        )}
      </div>
    </>
  );
}

export default App;
