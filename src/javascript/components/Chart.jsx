import React, { useState, useCallback, useEffect, useRef } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faArrowRight } from "@fortawesome/free-solid-svg-icons";
import * as d3 from "d3";

import { chart } from "../functions";

export const RegressionTypes = {
  POWER_LAW: 0,
  LINEAR: 1
};

const Chart = () => {
  const canvas = useRef(null);
  const [displayRegression, setDisplayRegression] = useState(true);
  const [regressionType, setRegressionType] = useState(true);
  const [values, setValues] = useState([]);

  const fetchValues = async () => {
    const data = await (await fetch(`/values`)).json();

    return data;
  };

  useEffect(() => {
    (async () => {
      const values = await fetchValues();

      chart(values, canvas.current);
      setValues(values);
    })();
  }, []);

  const handleRegressionDisplayChange = () => {
    setDisplayRegression(!displayRegression);

    chart(values, canvas.current, !displayRegression, regressionType);
  };

  const handleRegressionTypeChange = e => {
    setRegressionType(parseInt(e.currentTarget.value));

    chart(
      values,
      canvas.current,
      displayRegression,
      parseInt(e.currentTarget.value)
    );
  };

  return (
    <>
      <div className="d-flex justify-items-center" id="canvas-wrapper">
        <div id="canvas" ref={canvas}></div>
      </div>
      <div className="mt-3">
        <h6 className="text-muted">
          <strong>Regression</strong>
        </h6>
        <form>
          <div className="form-row">
            <div className="form-group col-3">
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
    </>
  );
};

export default Chart;
