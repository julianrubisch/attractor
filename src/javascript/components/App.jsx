import React, { useState, useEffect } from "react";

import Suggestions from "./Suggestions.jsx";
import Chart from "./Chart.jsx";
import Progress from "./Progress.jsx";

export default function App() {
  const [type, setType] = useState("rb");
  const [isLoading, setIsLoading] = useState(true);

  return (
    <>
      <Progress isAnimating={isLoading} />
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
        <ul className="navbar-nav mx-auto">
          <li className={`nav-item ${type === "rb" ? "active" : ""}`}>
            <a
              className="nav-link"
              href="#"
              onClick={() => {
                setType("rb");
              }}
            >
              Ruby
            </a>
          </li>
          <li className={`nav-item ${type === "js" ? "active" : ""}`}>
            <a
              className="nav-link"
              href="#"
              onClick={() => {
                setType("js");
              }}
            >
              Javascript
            </a>
          </li>
        </ul>
      </nav>
      <div className="container">
        <Chart type={type} />

        <div className="row mt-3">
          <div className="col-12">
            <Suggestions />
          </div>
        </div>
      </div>
    </>
  );
}
