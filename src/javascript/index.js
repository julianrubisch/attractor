import React from "react";
import ReactDOM from "react-dom";

import { scatterPlot } from "./functions";
import App from "./components/App.jsx";

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("react-root")) {
    ReactDOM.render(<App />, document.getElementById("react-root"));
  }
});

window.scatterPlot = scatterPlot;
