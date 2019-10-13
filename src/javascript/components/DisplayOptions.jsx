import React from "react";

const DisplayOptions = ({ state, dispatch }) => {
  const handleFilenamesDisplayChange = () => {
    dispatch({
      type: "SET_DISPLAY_FILENAMES",
      displayFilenames: !state.displayFilenames
    });
  };

  const handleRegressionTypeChange = e => {
    dispatch({
      type: "SET_REGRESSION_TYPE",
      regressionType: parseInt(e.currentTarget.value)
    });
  };

  const handleRegressionDisplayChange = () => {
    dispatch({
      type: "SET_DISPLAY_REGRESSION",
      displayRegression: !state.displayRegression
    });
  };

  return (
    <div className="mt-3">
      <h6 className="text-muted">
        <strong>Display options</strong>
      </h6>
      <form>
        <div className="form-row">
          <div className="form-group col-2">
            <input
              checked={state.displayFilenames}
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
              checked={state.displayRegression}
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
  );
};

export default DisplayOptions;
