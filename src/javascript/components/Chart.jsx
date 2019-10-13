import React, { useCallback, useReducer, useEffect, useRef } from "react";

import ActiveFileDetails from "./ActiveFileDetails";
import DisplayOptions from "./DisplayOptions";
import { scatterPlot } from "../functions";

export const RegressionTypes = {
  POWER_LAW: 0,
  LINEAR: 1
};

const initialState = {
  displayRegression: false,
  displayFilenames: false,
  regressionType: RegressionTypes.POWER_LAW,
  values: [],
  filePrefix: "",
  path: "",
  activeFile: {}
};

const Chart = () => {
  const reducer = (state, action) => {
    let newState = state;
    switch (action.type) {
      case "SET_DISPLAY_REGRESSION":
        newState = {
          ...state,
          displayRegression: action.displayRegression
        };
        break;
      case "SET_DISPLAY_FILENAMES":
        newState = {
          ...state,
          displayFilenames: action.displayFilenames
        };
        break;
      case "SET_REGRESSION_TYPE":
        newState = {
          ...state,
          regressionType: action.regressionType
        };
        break;
      case "SET_VALUES":
        newState = {
          ...state,
          values: action.values
        };
        break;
      case "SET_FILE_PREFIX":
        newState = {
          ...state,
          filePrefix: action.filePrefix
        };
        break;
      case "SET_PATH":
        newState = {
          ...state,
          path: action.path
        };
        break;
      case "SET_ACTIVE_FILE":
        newState = {
          ...state,
          activeFile: action.activeFile
        };
        break;
    }
    scatterPlot(canvas.current, newState, fileClickCallback);
    return newState;
  };

  const canvas = useRef(null);
  const [state, dispatch] = useReducer(reducer, initialState);

  const fetchValues = async () => {
    const data = await (await fetch(`/values`)).json();

    return data;
  };

  const fetchFilePrefix = async () => {
    const data = await (await fetch("/file_prefix")).json();

    return data;
  };

  function fileClickCallback(data) {
    dispatch({ type: "SET_ACTIVE_FILE", activeFile: data });
  }

  useEffect(() => {
    (async () => {
      const [values, filePrefix] = await Promise.all([
        fetchValues(),
        fetchFilePrefix()
      ]);

      dispatch({ type: "SET_VALUES", values });

      if (filePrefix["file_prefix"]) {
        dispatch({
          type: "SET_FILE_PREFIX",
          filePrefix: filePrefix["file_prefix"]
        });
      }

      scatterPlot(
        canvas.current,
        {
          values,
          displayRegression: false,
          regressionType: RegressionTypes.POWER_LAW,
          displayFilenames: false,
          filePrefix: filePrefix["file_prefix"] || "",
          path: "",
          activeFile: {}
        },
        fileClickCallback
      );
    })();
  }, []);

  const handlePathChange = e => {
    dispatch({
      type: "SET_PATH",
      path: e.target.value
    });
  };

  return (
    <div className="row">
      <div
        className={
          !state.activeFile || Object.keys(state.activeFile).length === 0
            ? "col-12"
            : "col-8"
        }
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
                        {`./${state.filePrefix || ""}`}
                      </span>
                    </div>
                    <input
                      type="text"
                      className="form-control"
                      placeholder=""
                      aria-label=""
                      aria-describedby="path-text"
                      id="path"
                      value={state.path}
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
            <DisplayOptions state={state} dispatch={dispatch} />
          </div>
        </div>
      </div>
      {state.activeFile && Object.keys(state.activeFile).length > 0 && (
        <ActiveFileDetails
          activeFile={state.activeFile}
          handleClose={() => {
            dispatch({
              type: "SET_ACTIVE_FILE",
              activeFile: {}
            });
          }}
        />
      )}
    </div>
  );
};

export default Chart;
