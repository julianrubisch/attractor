import React from "react";

const ActiveFileDetails = ({ activeFile, handleClose }) => (
  <div className="col-4">
    <div className="card">
      <div className="card-header">
        <h5 className="card-title">{activeFile.file_path}</h5>
        <h6 className="text-muted">Additional information</h6>
        <button
          type="button"
          className="close"
          aria-label="Close"
          onClick={handleClose}
        >
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div className="card-body">
        <h6 className="text-muted">
          <strong>Method Teardown</strong>
        </h6>
        <table className="table table-borderless mt-0 method-table">
          <tbody>
            {Object.entries(activeFile.details).map(([method, score]) => (
              <tr className="row" key={method}>
                <td className="px-3 py-1 col-9 text-truncate">{method}</td>
                <td className="px-3 py-1 col-3">
                  {Math.round(score * 100) / 100}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <h6 className="text-muted mt-3">Git history (last 10 commits)</h6>
        <table className="table table-borderless mt-0 method-table">
          <tbody>
            {activeFile.history.map(([commitRef, commitMessage]) => (
              <tr className="row" key={commitRef}>
                <td className="px-3 py-1 col-3 text-truncate">{commitRef}</td>
                <td className="px-3 py-1 col-8 text-truncate">
                  {commitMessage}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  </div>
);
export default ActiveFileDetails;
