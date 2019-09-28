import React, { useState, useEffect } from "react";

export default function Suggestions() {
  const [percentile, setPercentile] = useState(95);
  const [suggestions, setSuggestions] = useState([]);

  const fetchSuggestions = async percentile => {
    const data = await (await fetch(`/suggestions?p=${percentile}`)).json();
    setSuggestions(data);
    setPercentile(percentile);
  };

  useEffect(() => {
    fetchSuggestions(percentile);
  }, []);

  return (
    <table class="table mt-4">
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
  );
}
