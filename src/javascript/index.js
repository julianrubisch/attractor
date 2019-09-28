import React from "react";
import ReactDOM from "react-dom";

import { chart } from "./functions";
import Suggestions from "./components/Suggestions.jsx";

document.addEventListener("DOMContentLoaded", () => {
  const wrapper = document.getElementById("suggestions");
  if (wrapper) {
    ReactDOM.render(<Suggestions />, wrapper);
  }
});

window.chart = chart;
