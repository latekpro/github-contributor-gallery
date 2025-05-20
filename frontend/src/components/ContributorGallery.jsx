function ContributorGallery({ contributors }) {
  if (!contributors || contributors.length === 0) {
    return (
      <div className="empty-message">
        No contributors found for this repository.
      </div>
    );
  }

  return (
    <div className="gallery">
      {contributors.map((contributor) => (
        <div key={contributor.id} className="contributor-card">          <div className="avatar-container">
            <img
              src={contributor.avatar_url}
              alt={`${contributor.login}'s avatar`}
              className="avatar"
              title={`${contributor.login} - ${contributor.contributions} contributions`}
            />
          </div>
          <h3 className="username">
            <a href={contributor.html_url} target="_blank" rel="noopener noreferrer">
              {contributor.login}
            </a>
          </h3>
          <p className="contributions">
            {contributor.contributions} contribution{contributor.contributions !== 1 ? 's' : ''}
          </p>
        </div>
      ))}
    </div>
  );
}

export default ContributorGallery;
