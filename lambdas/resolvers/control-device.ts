export const handler = async (event: any) => {
  console.log('rule-engine event:', event);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from rule-engine!' }),
  };
};