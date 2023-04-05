exports.handler = async (event) => {
    // extract parameters from the event object
    // const { id } = event.queryStringParameters;

    // perform some business logic
    // const book = getBookById(id);

    // create the response object
    const response = {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify("ALL GOOD")
    };

    // return the response
    return response;
};