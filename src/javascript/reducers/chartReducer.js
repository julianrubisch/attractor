const reducer = (state, action) => {
  let newState = state;
  switch (action.type) {
    case "SET_DISPLAY_REGRESSION":
      newState = {
        ...state,
        displayRegression: action.displayRegression
      };
      break;
    case "SET_DISPLAY_FILENAMES":
      newState = {
        ...state,
        displayFilenames: action.displayFilenames
      };
      break;
    case "SET_REGRESSION_TYPE":
      newState = {
        ...state,
        regressionType: action.regressionType
      };
      break;
    case "SET_MEASUREMENT_TYPE":
      newState = {
        ...state,
        measurementType: action.measurementType
      };
      break;
    case "SET_VALUES":
      newState = {
        ...state,
        values: action.values
      };
      break;
    case "SET_FILE_PREFIX":
      newState = {
        ...state,
        filePrefix: action.filePrefix
      };
      break;
    case "SET_PATH":
      newState = {
        ...state,
        path: action.path
      };
      break;
    case "SET_ACTIVE_FILE":
      newState = {
        ...state,
        activeFile: action.activeFile
      };
      break;
  }
  return newState;
};

export default reducer;
