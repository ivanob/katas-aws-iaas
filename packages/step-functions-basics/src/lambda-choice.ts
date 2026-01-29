
exports.handler = async (event) => {
  console.log(`Hello ${event.name}`)
  let option = "Option2"
  if(Math.random()<0.75){
    option = "Option1"
  }
  return {
    result: option
  }
};
