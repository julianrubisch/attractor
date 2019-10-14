import React, { useRef, useEffect } from "react";

import { scatterPlot } from "../functions";

const ScatterPlot = ({
  fileClickCallback,
  values,
  filePrefix,
  displayRegression,
  regressionType,
  displayFilenames,
  path,
  activeFile
}) => {
  const canvas = useRef(null);

  useEffect(() => {
    scatterPlot(
      canvas.current,
      {
        values,
        displayRegression,
        regressionType,
        displayFilenames,
        filePrefix,
        path,
        activeFile
      },
      fileClickCallback
    );
  });
  return <div id="canvas" ref={canvas}></div>;
};

export default ScatterPlot;
