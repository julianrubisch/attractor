import React, { useState, useEffect } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faArrowRight } from "@fortawesome/free-solid-svg-icons";

export default function Suggestions() {
  const [percentile, setPercentile] = useState(95);
  const [suggestions, setSuggestions] = useState([]);

  const fetchSuggestions = async percentile => {
    const data = await (await fetch(`/suggestions?t=${percentile}`)).json();
    setSuggestions(data);
  };

  const refreshSuggestions = e => {
    e.preventDefault();

    fetchSuggestions(percentile);
  };

  useEffect(() => {
    fetchSuggestions(percentile);
  }, []);

  return (
    <div className="card">
      <div className="card-body">
        <div className="d-flex justify-content-between">
          <div>
            <h5 className="card-title">Refactoring Candidates</h5>
            <h6 className="card-subtitle text-muted">
              Top 95 Percentile of Churn * Complexity
            </h6>
          </div>
          <div id="percentile-input-group">
            <label htmlFor="percentile" className="text-muted">
              <small>Percentile</small>
            </label>
            <div className="input-group align-items-start">
              <input
                type="text"
                className="form-control"
                placeholder=""
                aria-label=""
                aria-describedby="percentile-button"
                id="percentile"
                value={percentile}
                onChange={e => setPercentile(e.target.value)}
              />
              <div className="input-group-append">
                <button
                  className="btn btn-dark"
                  type="button"
                  id="percentile-button"
                  onClick={refreshSuggestions}
                >
                  <FontAwesomeIcon icon={faArrowRight} />
                </button>
              </div>
            </div>
          </div>
        </div>
        <table className="table mt-4">
          <thead>
            <tr>
              <th scope="col">File Path</th>
              <th scope="col">Churn</th>
              <th scope="col">Complexity</th>
              <th scope="col">Churn * Complexity</th>
            </tr>
          </thead>
          <tbody id="suggestions-table">
            {suggestions.map(sugg => (
              <tr key={sugg.file_path}>
                <td>{sugg.file_path}</td>
                <td>{sugg.x}</td>
                <td>{Math.round(sugg.y)}</td>
                <td>{Math.round(sugg.x * sugg.y)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
