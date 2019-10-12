import React, {
  useState,
  useCallback,
  useReducer,
  useEffect,
  useRef
} from "react";

import ActiveFileDetails from "./ActiveFileDetails";
import DisplayOptions from "./DisplayOptions";
import { chart } from "../functions";

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

const reducer = (state, action) => {
  switch (action.type) {
    case "SET_DISPLAY_REGRESSION":
      return {
        ...state,
        displayRegression: action.displayRegression
      };
    case "SET_DISPLAY_FILENAMES":
      return {
        ...state,
        displayFilenames: action.displayFilenames
      };
    case "SET_REGRESSION_TYPE":
      return {
        ...state,
        regressionType: action.regressionType
      };
    case "SET_VALUES":
      return {
        ...state,
        values: action.values
      };
    case "SET_FILE_PREFIX":
      return {
        ...state,
        filePrefix: action.filePrefix
      };
    case "SET_PATH":
      return {
        ...state,
        path: action.path
      };
    case "SET_ACTIVE_FILE":
      return {
        ...state,
        activeFile: action.activeFile
      };
  }
};

const Chart = () => {
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

  const fileClickCallback = data => {
    dispatch({ type: "SET_ACTIVE_FILE", activeFile: data });
  };

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
    dispatch({
      type: "SET_DISPLAY_REGRESSION",
      displayRegression: !state.displayRegression
    });

    chart(
      state.values,
      canvas.current,
      !state.displayRegression,
      state.regressionType,
      state.displayFilenames,
      `${state.filePrefix}${state.path}`,
      fileClickCallback
    );
  };

  const handleFilenamesDisplayChange = () => {
    dispatch({
      type: "SET_DISPLAY_REGRESSION",
      displayFilenames: !state.displayFilenames
    });

    chart(
      state.values,
      canvas.current,
      state.displayRegression,
      state.regressionType,
      !state.displayFilenames,
      `${state.filePrefix}${state.path}`,
      fileClickCallback
    );
  };

  const handleRegressionTypeChange = e => {
    dispatch({
      type: "SET_REGRESSION_TYPE",
      regressionType: parseInt(e.currentTarget.value)
    });

    chart(
      state.values,
      canvas.current,
      state.displayRegression,
      parseInt(e.currentTarget.value),
      state.displayFilenames,
      `${state.filePrefix}${state.path}`,
      fileClickCallback
    );
  };

  const handlePathChange = e => {
    dispatch({
      type: "SET_PATH",
      path: e.target.value
    });

    chart(
      state.values,
      canvas.current,
      state.displayRegression,
      state.regressionType,
      state.displayFilenames,
      `${state.filePrefix}${e.target.value}`,
      fileClickCallback
    );
  };

  return (
    <div className="row">
      <div
        className={
          Object.keys(state.activeFile).length === 0 ? "col-12" : "col-8"
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
            <DisplayOptions state={state} dispath={dispatch} />
          </div>
        </div>
      </div>
      {Object.keys(state.activeFile).length > 0 && (
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
