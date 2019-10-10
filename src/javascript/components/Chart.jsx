import React, { useState, useCallback, useEffect, useRef } from "react";

import { chart } from "../functions";

export const RegressionTypes = {
  POWER_LAW: 0,
  LINEAR: 1
};

const Chart = () => {
  const canvas = useRef(null);
  const [displayRegression, setDisplayRegression] = useState(false);
  const [displayFilenames, setDisplayFilenames] = useState(false);
  const [regressionType, setRegressionType] = useState(true);
  const [values, setValues] = useState([]);
  const [filePrefix, setFilePrefix] = useState("");
  const [path, setPath] = useState("");
  const [activeFile, setActiveFile] = useState({});

  const fetchValues = async () => {
    const data = await (await fetch(`/values`)).json();

    return data;
  };

  const fetchFilePrefix = async () => {
    const data = await (await fetch("/file_prefix")).json();

    return data;
  };

  const fileClickCallback = data => {
    setActiveFile(data);
  };

  useEffect(() => {
    (async () => {
      const [values, filePrefix] = await Promise.all([
        fetchValues(),
        fetchFilePrefix()
      ]);

      setValues(values);

      if (filePrefix["file_prefix"]) {
        setFilePrefix(filePrefix["file_prefix"]);
      }

      chart(
        values,
        canvas.current,
        false,
        RegressionTypes.POWER_LAW,
        false,
        filePrefix["file_prefix"] || "",
        fileClickCallback
      );
    })();
  }, []);

  const handleRegressionDisplayChange = () => {
    setDisplayRegression(!displayRegression);

    chart(
      values,
      canvas.current,
      !displayRegression,
      regressionType,
      displayFilenames,
      `${filePrefix}${path}`,
      fileClickCallback
    );
  };

  const handleFilenamesDisplayChange = () => {
    setDisplayFilenames(!displayFilenames);

    chart(
      values,
      canvas.current,
      displayRegression,
      regressionType,
      !displayFilenames,
      `${filePrefix}${path}`,
      fileClickCallback
    );
  };

  const handleRegressionTypeChange = e => {
    setRegressionType(parseInt(e.currentTarget.value));

    chart(
      values,
      canvas.current,
      displayRegression,
      parseInt(e.currentTarget.value),
      displayFilenames,
      `${filePrefix}${path}`,
      fileClickCallback
    );
  };

  const handlePathChange = e => {
    setPath(e.target.value);

    chart(
      values,
      canvas.current,
      displayRegression,
      regressionType,
      displayFilenames,
      `${filePrefix}${e.target.value}`,
      fileClickCallback
    );
  };

  return (
    <div className="row">
      <div
        className={Object.keys(activeFile).length === 0 ? "col-12" : "col-8"}
      >
        <div className="card">
          <div className="card-header">
            <h5 className="card-title">Churn vs Complexity</h5>
            <h6 className="text-muted">
              Click on a point for additional information
            </h6>
          </div>
          <div className="card-body">
            <div className="row">
              <div className="col-2 col-lg-3" />
              <div className="col-8 col-lg-6">
                <div id="path-input-group">
                  <label htmlFor="path" className="text-muted">
                    <small>Base Path</small>
                  </label>
                  <div className="input-group mb-3">
                    <div className="input-group-prepend">
                      <span className="input-group-text" id="path-text">
                        {`./${filePrefix || ""}`}
                      </span>
                    </div>
                    <input
                      type="text"
                      className="form-control"
                      placeholder=""
                      aria-label=""
                      aria-describedby="path-text"
                      id="path"
                      value={path}
                      onChange={handlePathChange}
                    />
                  </div>
                </div>
              </div>
              <div className="col-2 col-lg-3" />
            </div>
            <div className="d-flex justify-items-center" id="canvas-wrapper">
              <div id="canvas" ref={canvas}></div>
            </div>
            <div className="mt-3">
              <h6 className="text-muted">
                <strong>Display options</strong>
              </h6>
              <form>
                <div className="form-row">
                  <div className="form-group col-2">
                    <input
                      checked={displayFilenames}
                      className="form-check-input"
                      type="checkbox"
                      id="filenames-check"
                      onChange={handleFilenamesDisplayChange}
                    />
                    <label
                      className="form-check-label text-muted"
                      htmlFor="filenames-check"
                    >
                      <small>Display filenames</small>
                    </label>
                  </div>
                  <div className="form-group col-2">
                    <input
                      checked={displayRegression}
                      className="form-check-input"
                      type="checkbox"
                      id="regression-check"
                      onChange={handleRegressionDisplayChange}
                    />
                    <label
                      className="form-check-label text-muted"
                      htmlFor="regression-check"
                    >
                      <small>Display regression</small>
                    </label>
                  </div>
                  <div className="form-group col-3">
                    <label htmlFor="regression-type" className="text-muted">
                      <small>Regression Type</small>
                    </label>
                    <select
                      id="regression-type"
                      className="form-control"
                      onChange={handleRegressionTypeChange}
                    >
                      <option selected value="0">
                        Power Law
                      </option>
                      <option value="1">Linear</option>
                    </select>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
      {Object.keys(activeFile).length > 0 && (
        <div className="col-4">
          <div className="card">
            <div className="card-header">
              <h5 className="card-title">{activeFile.file_path}</h5>
              <h6 className="text-muted">Additional information</h6>
              <button
                type="button"
                className="close"
                aria-label="Close"
                onClick={() => {
                  setActiveFile({});
                }}
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
                      <td className="px-3 py-1 col-9 text-truncate">
                        {method}
                      </td>
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
                      <td className="px-3 py-1 col-3 text-truncate">
                        {commitRef}
                      </td>
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
      )}
    </div>
  );
};

export default Chart;
