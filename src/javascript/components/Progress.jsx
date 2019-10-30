import { useNProgress } from "@tanem/react-nprogress";
import React from "react";
import Bar from "./Bar";
import Container from "./Container";

const Progress = ({ isAnimating }) => {
  const { animationDuration, isFinished, progress } = useNProgress({
    isAnimating
  });

  return (
    <Container isFinished={isFinished} animationDuration={animationDuration}>
      <Bar progress={progress} animationDuration={animationDuration} />
    </Container>
  );
};

export default Progress;
