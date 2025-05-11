export const handler = async (event: any) => {
  console.log('get-ui-page event:', event);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from get-ui-page!' }),
  };
};