import PropTypes from "prop-types";
import * as React from "react";

const Bar = ({ progress, animationDuration }) => (
  <div
    className="progressbar"
    style={{
      marginLeft: `${(-1 + progress) * 100}%`,
      transition: `margin-left ${animationDuration}ms linear`
    }}
  >
    <div className="shadow" />
  </div>
);

Bar.propTypes = {
  animationDuration: PropTypes.number.isRequired,
  progress: PropTypes.number.isRequired
};

export default Bar;
