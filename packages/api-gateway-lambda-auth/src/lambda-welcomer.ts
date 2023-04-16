exports.handler = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Welcome!!",
    }),
    headers: {
      "Content-Type": "application/json",
    },
  };
};
