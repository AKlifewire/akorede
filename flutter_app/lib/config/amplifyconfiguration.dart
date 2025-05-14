const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify/cli",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_UnagOLQSa",
            "AppClientId": "1jmho6eejlk0ndiemgkkaoarpi",
            "Region": "us-east-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH"
          }
        },
        "CognitoIdentity": {
          "Default": {
            "IdentityPoolId": "us-east-1:a3526ae0-66dd-49ea-a20c-046bb2277087",
            "Region": "us-east-1"
          }
        }
      }
    }
  },
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "SmartHomeAPI": {
          "endpointType": "GraphQL",
          "endpoint": "https://pygewtdlpze3bcesak5siyg7am.appsync-api.us-east-1.amazonaws.com/graphql",
          "region": "us-east-1",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "uistack-uibucketb980636d-5hxah7548zp9",
        "region": "us-east-1"
      }
    }
  }
}''';