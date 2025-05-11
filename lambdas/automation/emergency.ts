export const handler = async (event: any) => {
  console.log('emergency event:', event);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from emergency!' }),
  };
};