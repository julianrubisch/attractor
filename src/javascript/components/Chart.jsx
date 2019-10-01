import React, { useState, useEffect, useRef } from "react";
import * as d3 from "d3";

import { chart } from "../functions";

const Chart = () => {
  const canvas = useRef(null);

  const fetchValues = async () => {
    const data = await (await fetch(`/values`)).json();

    return data;
  };

  useEffect(() => {
    (async () => {
      const values = await fetchValues();

      chart(values, canvas.current);
    })();
  }, []);

  return (
    <>
      <div ref={canvas}></div>
    </>
  );
};

export default Chart;
