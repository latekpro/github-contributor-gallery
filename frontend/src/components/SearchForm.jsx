import { useState } from 'react';

function SearchForm({ onSearch }) {
  const [owner, setOwner] = useState('');
  const [repo, setRepo] = useState('');
  const [formError, setFormError] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Basic form validation
    if (!owner.trim() || !repo.trim()) {
      setFormError('Both owner and repository name are required');
      return;
    }
    
    // Clear any previous form errors
    setFormError('');
    
    // Call the search function from the parent component
    onSearch(owner.trim(), repo.trim());
  };

  return (
    <div className="search-container">
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="owner">GitHub Username/Organization:</label>
          <input
            type="text"
            id="owner"
            value={owner}
            onChange={(e) => setOwner(e.target.value)}
            placeholder="e.g., facebook"
            required
          />
        </div>
        
        <div className="form-group">
          <label htmlFor="repo">Repository Name:</label>
          <input
            type="text"
            id="repo"
            value={repo}
            onChange={(e) => setRepo(e.target.value)}
            placeholder="e.g., react"
            required
          />
        </div>
        
        {formError && <div className="error">{formError}</div>}
        
        <button type="submit">Search Contributors</button>
      </form>
    </div>
  );
}

export default SearchForm;
