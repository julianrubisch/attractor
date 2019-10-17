import React, { useRef, useEffect } from "react";

import { histogram } from "../functions";

const Histogram = ({
  fileClickCallback,
  values,
  filePrefix,
  displayRegression,
  regressionType,
  measurementType,
  displayFilenames,
  path,
  activeFile
}) => {
  const canvas = useRef(null);

  useEffect(() => {
    histogram(
      canvas.current,
      {
        values,
        displayRegression,
        regressionType,
        measurementType,
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

export default Histogram;
