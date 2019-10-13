import React from "react";
import ReactDOM from "react-dom";

import { scatterPlot } from "./functions";
import Suggestions from "./components/Suggestions.jsx";
import Chart from "./components/Chart.jsx";

document.addEventListener("DOMContentLoaded", () => {
  if (document.getElementById("react-graph")) {
    ReactDOM.render(<Chart />, document.getElementById("react-graph"));
    ReactDOM.render(
      <Suggestions />,
      document.getElementById("react-suggestions")
    );
  }
});

window.scatterPlot = scatterPlot;
