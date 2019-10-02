import React, { useState, useEffect, useRef } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faArrowRight } from "@fortawesome/free-solid-svg-icons";
import * as d3 from "d3";

import { chart } from "../functions";

const Chart = () => {
  const canvas = useRef(null);
  const [state, setState] = useState({ displayRegression: true });

  const fetchValues = async () => {
    const data = await (await fetch(`/values`)).json();

    return data;
  };

  useEffect(() => {
    (async () => {
      const values = await fetchValues();

      chart(values, canvas.current);
    })();
  }, []);

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
                checked={state.displayRegression}
                className="form-check-input"
                type="checkbox"
                id="regression-check"
                onChange={() => {
                  setState({
                    ...state,
                    displayRegression: !state.displayRegression
                  });
                }}
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
              <div className="input-group align-items-start">
                <input
                  type="text"
                  className="form-control"
                  placeholder=""
                  aria-label=""
                  aria-describedby="percentile-button"
                  id="regression-type"
                  /* value={percentile} */
                  /* onChange={e => setPercentile(e.target.value)} */
                />
                <div className="input-group-append">
                  <button
                    className="btn btn-dark"
                    type="button"
                    id="percentile-button"
                  >
                    <FontAwesomeIcon icon={faArrowRight} />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </form>
      </div>
    </>
  );
};

export default Chart;
