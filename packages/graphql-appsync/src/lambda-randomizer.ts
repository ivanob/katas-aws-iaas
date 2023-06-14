
exports.handler = async (event) => {
  return {
    random: Math.floor(Math.random() * 10) + 1
  };
};
