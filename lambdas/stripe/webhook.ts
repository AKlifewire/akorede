export const handler = async (event: any) => {
  console.log('stripe-webhook event:', event);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from stripe-webhook!' }),
  };
};