import { NProgress } from "@tanem/react-nprogress";
import React from "react";
import Bar from "./Bar";
import Container from "./Container";

const Progress = ({ isAnimating, key }) => {
  return (
    <NProgress isAnimating={isAnimating} key={key}>
      {({ animationDuration, isFinished, progress }) => (
        <Container
          isFinished={isFinished}
          animationDuration={animationDuration}
        >
          <Bar progress={progress} animationDuration={animationDuration} />
        </Container>
      )}
    </NProgress>
  );
};

export default Progress;
