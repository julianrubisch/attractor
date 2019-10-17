import React, { useRef, useEffect } from "react";

import { treemap } from "../functions";

const TreeMap = ({
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
    treemap(
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

export default TreeMap;
