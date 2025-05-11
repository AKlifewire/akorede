export const handler = async (event: any) => {
  console.log('device-control event:', event);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from device-control!' }),
  };
};