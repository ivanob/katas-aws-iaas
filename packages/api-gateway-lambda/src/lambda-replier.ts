import { v4 as uuidv4 } from "uuid";

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
  switch (event.httpMethod) {
    case "GET":
      return get_user(event);
    case "POST":
      return post_user(event);
    default:
      return {
        statusCode: 405,
        body: JSON.stringify({
          Error: "Only methods supported are: GET and POST",
        }),
        headers: {
          "Content-Type": "application/json",
        },
      };
  }
};

const post_user = (event) => {
  let response = {};
  // extract parameters from the event object
  if (!event.body) {
    response = {
      statusCode: 400,
      body: JSON.stringify({
        Error: "The client forgot to specify the body parameters",
      }),
    };
  }
  try {
    const { name, login, age } = JSON.parse(event.body);
    if (!name || !login || !age) {
      response = {
        statusCode: 400,
        body: JSON.stringify({
          Error:
            "The client needs to specify: name, login, and age for a new user",
        }),
      };
    } else {
      const newUser: User = { name, login, age, id: uuidv4() };
      mockDB.push(newUser);
      // ...Although does not make much sense, as DB is destroyed after each execution :D
      response = {
        statusCode: 200,
        body: JSON.stringify({
          Message: `New user created succesfully: ${JSON.stringify(newUser)}`,
        }),
      };
    }
  } catch (error) {
    response = {
      statusCode: 400,
      body: JSON.stringify({
        Error:
          "Error in the parameters format. Did you forgot the quotes in the parameters names and values?",
      }),
    };
  }
  // return the response
  return {
    ...response,
    headers: {
      "Content-Type": "application/json",
    },
  };
};

const get_user = (event) => {
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
    if (user) {
      response = {
        statusCode: 200,
        body: JSON.stringify(user),
      };
    } else {
      response = {
        statusCode: 404,
        body: JSON.stringify({ Error: "User not found" }),
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
