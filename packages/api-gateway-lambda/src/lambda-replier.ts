type User = {
  id: string;
  name: string;
  login: string;
  age: number;
};

const mockDB: User[] = [
  {
    id: "111111",
    name: "John",
    login: "john.doe",
    age: 35,
  },
  {
    id: "222222",
    name: "Paul",
    login: "paul.smith",
    age: 30,
  },
  {
    id: "333333",
    name: "Steve",
    login: "steve.jackson",
    age: 27,
  },
];

exports.handler = async (event) => {
  let response = {};
  // extract parameters from the event object
  if (!event.queryStringParameters || !event.queryStringParameters.id) {
    response = {
      statusCode: 400,
      body: JSON.stringify({
        Error: "The client forgot to specify the id parameter",
      }),
    };
  } else {
    const { id } = event.queryStringParameters;
    const user: User | undefined = mockDB.find((u) => u.id === id);
    // create the response object
    if(user){
        response = {
          statusCode: 200,
          body: JSON.stringify(user),
        };
    }else{
        response = {
            statusCode: 404,
            body: JSON.stringify({Error: "User not found"}),
          };
    }

  }

  // return the response
  return {
    ...response,
    headers: {
      "Content-Type": "application/json",
    },
  };
};
