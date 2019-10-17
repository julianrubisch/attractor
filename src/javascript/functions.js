import * as d3 from "d3";
import { regressionPow, regressionLinear } from "d3-regression";
import "d3-tile";
import { group } from "d3-array";

import { RegressionTypes, MeasurementTypes } from "./components/Chart";

const regressionLabel = (regressionType, regressionData) => {
  switch (regressionType) {
    case RegressionTypes.LINEAR:
      return `y = ${regressionData.a.toFixed(2)} x + ${regressionData.b.toFixed(
        2
      )}`;
    case RegressionTypes.POWER_LAW:
    default:
      return `y = ${regressionData.a.toFixed(2)} x ^ ${regressionData.b.toFixed(
        2
      )}`;
  }
};

const makeTreemap = (data, width, height) =>
  d3
    .treemap()
    .tile(d3["treemapSquarify"])
    .size([width, height])
    .padding(1)
    .round(true)(
    d3
      .hierarchy(data)
      .sum(d => d.value)
      .sort((a, b) => b.value - a.value)
  );

const format = d3.format(",d");

const addLeafText = leaf => {
  leaf
    .append("text")
    // .attr("clip-path", d => d.clipUid)
    .selectAll("tspan")
    .data(d => d.data.name.concat(format(d.value)))
    .join("tspan")
    .attr("x", 3)
    .attr(
      "y",
      (d, i, nodes) => `${(i === nodes.length - 1) * 0.3 + 1.1 + i * 0.9}em`
    )
    .attr("fill-opacity", (d, i, nodes) =>
      i === nodes.length - 1 ? 0.7 : null
    )
    .text(d => d);
};

export const treemap = (
  canvas,
  {
    values: data,
    displayRegression = true,
    regressionType = 0,
    measurementType = 0,
    displayFilenames = false,
    filePrefix = "",
    path = "",
    activeFile = {}
  },
  callback = () => {}
) => {
  canvas.innerHTML = "";
  const width = 600;
  const height = 600;

  const color = d3.scaleOrdinal(d3.schemeCategory10);

  data = data.filter(d => d.file_path.startsWith(`${filePrefix}${path}`));

  const dataSplitPath = data
    .map(d => {
      let value;
      switch (measurementType) {
        case MeasurementTypes.COMPLEXITY:
          value = d.y;
          break;
        case MeasurementTypes.CHURN:
          value = d.x;
          break;
        case MeasurementTypes.CHURN_COMPLEXITY:
        default:
          value = d.y * d.x;
      }
      return {
        name: d.file_path.substring(filePrefix.length + 1),
        value,
        file_path: d.file_path,
        details: d.details,
        history: d.history
      };
    })
    .map(d => ({
      name: d.name.split("/"),
      value: d.value,
      file_path: d.file_path,
      details: d.details,
      history: d.history
    }));

  const sanitizedData = {
    name: filePrefix,
    children: Array.from(
      group(dataSplitPath, d => d.name[0]),
      ([name, children]) => ({
        name,
        children: Array.from(
          group(children, d => d.name[1]),
          ([name, children]) => ({ name, children })
        )
      })
    )
  };

  const svgCanvas = d3
    .select(canvas)
    .append("svg")
    .attr("viewBox", [0, 0, width, height])
    .style("font-size", "10px");

  if (sanitizedData.children.length > 0) {
    const root = makeTreemap(sanitizedData, width, height);

    const leaf = svgCanvas
      .selectAll("g")
      .data(root.leaves())
      .join("g")
      .attr("transform", d => `translate(${d.x0},${d.y0})`);

    leaf.append("title").text(
      d =>
        `${d
          .ancestors()
          .reverse()
          .map(d => d.data.name)
          .join("/")}\n${format(d.value)}`
    );

    leaf
      .append("rect")
      // .attr("id", d => (d.leafUid = DOM.uid("leaf")).id)
      .attr("fill", d => {
        while (d.depth > 1) d = d.parent;
        return color(d.data.name);
      })
      .attr("fill-opacity", 0.6)
      .attr("width", d => d.x1 - d.x0)
      .attr("height", d => d.y1 - d.y0)
      .on("click", d => {
        callback(d.data);
      });

    // leaf
    // .append("clipPath")
    // .attr("id", d => (d.clipUid = DOM.uid("clip")).id)
    // .append("use");
    // .attr("xlink:href", d => d.leafUid.href);

    if (displayFilenames) {
      addLeafText(leaf);
    }
  }
};

export const scatterPlot = (
  canvas,
  {
    values: data,
    displayRegression = true,
    regressionType = 0,
    displayFilenames = false,
    filePrefix = "",
    path = "",
    activeFile = {}
  },
  callback = () => {}
) => {
  canvas.innerHTML = "";
  const width = 600;
  const height = 600;

  data = data.filter(d => d.file_path.startsWith(`${filePrefix}${path}`));

  const margin = { top: 20, right: 30, bottom: 30, left: 40 };

  const borderColor = d3
    .scaleLog()
    .domain(d3.extent(data.filter(d => d.y > 0), d => d.x * d.y))
    .range(["green", "red"]);

  const fillColor = d3
    .scaleLog()
    .domain(d3.extent(data.filter(d => d.y > 0), d => d.x * d.y))
    .range(["lightgreen", "tomato"]);

  const xScale = d3
    .scaleLinear()
    .domain(d3.extent(data, d => d.x))
    .nice()
    .range([margin.left, width - margin.right]);

  const yScale = d3
    .scaleLinear()
    .domain(d3.extent(data, d => d.y))
    .nice()
    .range([height - margin.bottom, margin.top]);

  const xAxis = g =>
    g
      .attr("transform", `translate(0,${height - margin.bottom})`)
      .call(d3.axisBottom(xScale))
      .call(g => g.select(".domain").remove())
      .call(g =>
        g
          .append("text")
          .attr("x", width / 2 + margin.left)
          .attr("y", 30)
          .attr("fill", "#000")
          .attr("font-size", 12)
          .attr("font-weight", "bold")
          .attr("text-anchor", "end")
          .text("Churn")
      );

  const yAxis = g =>
    g
      .attr("transform", `translate(${margin.left},0)`)
      .call(d3.axisLeft(yScale))
      .call(g => g.select(".domain").remove())
      .call(g =>
        g
          .append("text")
          .attr("y", -30)
          .attr("x", -height / 2)
          .attr("transform", "rotate(-90)")
          .attr("fill", "#000")
          .attr("font-size", 12)
          .attr("text-anchor", "start")
          .attr("font-weight", "bold")
          .text("Complexity")
      );

  const lineGenerator = d3
    .line()
    .x(d => xScale(d[0]))
    .y(d => yScale(d[1]));

  const svgCanvas = d3
    .select(canvas)
    .append("svg")
    .attr("viewBox", [0, 0, width, height]);

  const g = svgCanvas.append("g");

  g.append("g")
    .attr("class", "axis")
    .call(xAxis)
    .selectAll(".tick line")
    .classed("baseline", d => d === 0);

  g.append("g")
    .attr("class", "axis")
    .call(yAxis)
    .selectAll(".tick line")
    .classed("baseline", d => d === 0);

  g.append("g")
    .attr("stroke-width", 1.5)
    .attr("font-family", "Red Hat Text")
    .attr("font-size", 12)
    .selectAll("g")
    .data(data)
    .join("g")
    .attr("transform", d => `translate(${xScale(d.x)},${yScale(d.y)})`)
    .call(g =>
      g
        .append("circle")
        .attr("fill", d => fillColor(d.x * d.y))
        .attr("stroke", d => borderColor(d.x * d.y))
        .attr("style", "cursor:pointer")
        .attr("r", 4)
    )
    .call(g => {
      if (displayFilenames) {
        return g
          .append("text")
          .attr("dy", "0.35em")
          .attr("x", 7)
          .attr("style", "cursor:pointer")
          .text(d => d.file_path);
      } else {
        return null;
      }
    })
    .on("click", d => {
      callback(d);
    });

  if (displayRegression) {
    const regressionGenerator = (function(regressionType) {
      switch (regressionType) {
        case RegressionTypes.LINEAR:
          return regressionLinear()
            .x(d => d.x)
            .y(d => d.y)
            .domain([3, d3.max(data, item => item.x)]);
        case RegressionTypes.POWER_LAW:
        default:
          data = data.filter(d => d.y > 0);
          return regressionPow()
            .x(d => d.x)
            .y(d => d.y)
            .domain([3, d3.max(data, item => item.x)]);
      }
    })(regressionType);

    const regressionData = regressionGenerator(data);

    g.append("g")
      .attr("font-family", "Red Hat Text")
      .attr("font-size", 24)
      .call(g =>
        g
          .append("path")
          .attr("class", "regression")
          .datum(regressionGenerator(data))
          .attr("d", lineGenerator)
      )
      .call(g =>
        g
          .append("text")
          .attr("dy", "60")
          .attr("dx", "33%")
          .text(`R^2 = ${regressionData.rSquared.toFixed(2)}`)
      )
      .call(g =>
        g
          .append("text")
          .attr("dy", "30")
          .attr("dx", "33%")
          .text(regressionLabel(regressionType, regressionData))
      );
  }
};
