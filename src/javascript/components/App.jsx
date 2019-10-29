import React, { useState, useEffect } from "react";

import Suggestions from "./Suggestions.jsx";
import Chart from "./Chart.jsx";

export default function App() {
  const [type, setType] = useState("rb");

  return (
    <>
      <nav className="navbar navbar-expand-lg navbar-light bg-light fixed-top">
        <a className="navbar-brand" href="#">
          <img
            src="images/attractor_logo.svg"
            alt=""
            width="36"
            className="mr-3"
          ></img>
          Attractor
        </a>
      </nav>
      <div className="container">
        <Chart />

        <div className="row mt-3">
          <div className="col-12">
            <Suggestions />
          </div>
        </div>
      </div>
    </>
  );
}
