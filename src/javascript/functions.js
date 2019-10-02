import * as d3 from "d3";
import { regressionPow } from "d3-regression";

export const chart = (data, canvas, displayRegression = true) => {
  canvas.innerHTML = "";
  const width = 600;
  const height = 600;

  const margin = { top: 20, right: 30, bottom: 30, left: 40 };

  const color = d3
    .scaleLog()
    .domain(d3.extent(data, d => d.x * d.y))
    .range(["green", "red"]);

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
          .attr("x", width - margin.right)
          .attr("y", -4)
          .attr("fill", "#000")
          .attr("font-weight", "bold")
          .attr("text-anchor", "end")
          .text(data.x)
      );

  const yAxis = g =>
    g
      .attr("transform", `translate(${margin.left},0)`)
      .call(d3.axisLeft(yScale))
      .call(g => g.select(".domain").remove())
      .call(g =>
        g
          .select(".tick:last-of-type text")
          .clone()
          .attr("x", 4)
          .attr("text-anchor", "start")
          .attr("font-weight", "bold")
          .text(data.y)
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
        .attr("fill", d => color(d.x * d.y))
        .attr("stroke", d => color(d.x * d.y))
        .attr("r", 4)
    )
    .call(g =>
      g
        .append("text")
        .attr("dy", "0.35em")
        .attr("x", 7)
        .text(d => d.file_path)
    );

  if (displayRegression) {
    const regressionGenerator = regressionPow()
      .x(d => d.x)
      .y(d => d.y)
      .domain([0, d3.max(data, item => item.x)]);

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
          .text(
            `y = ${regressionData.a.toFixed(2)} x ^ ${regressionData.b.toFixed(
              2
            )}`
          )
      );
  }
};
