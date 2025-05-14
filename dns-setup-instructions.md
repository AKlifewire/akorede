# DNS Setup Instructions for ak.lifewire.com

To connect your custom domain `ak.lifewire.com` to your Amplify app, you need to add the following DNS records to your domain's DNS configuration:

## Certificate Validation Record

First, you need to validate the SSL certificate by adding this CNAME record:

```
Name: _e3fed619010167f92c6d7cde7ed385ab.ak.lifewire.com
Type: CNAME
Value: _03ae0dcbda422f3177d76d3bb13dc5c1.zfyfvmchrl.acm-validations.aws.
```

## Domain Mapping Record

After the certificate is validated, add this CNAME record to point your domain to the Amplify app:

```
Name: ak.lifewire.com
Type: CNAME
Value: djbk1xo57dd8q.cloudfront.net
```

## Steps to Add DNS Records

1. Log in to your domain registrar or DNS provider (e.g., GoDaddy, Namecheap, Route 53)
2. Navigate to the DNS management section
3. Add the certificate validation CNAME record
4. Wait for the certificate to be validated (this can take up to 24 hours)
5. Add the domain mapping CNAME record
6. Wait for DNS propagation (this can take up to 48 hours)

## Verification

You can check the status of your domain association by running:

```bash
aws amplify get-domain-association --app-id d1f03wrn5jeguf --domain-name ak.lifewire.com
```

Once the domain status changes from `PENDING_VERIFICATION` to `AVAILABLE`, your custom domain is ready to use.

## Accessing Your App

After DNS propagation is complete, you can access your app at:

- Custom domain: https://ak.lifewire.com
- Default domain: https://main.d1f03wrn5jeguf.amplifyapp.com

## Troubleshooting

If you encounter issues with the domain setup:

1. Verify that the DNS records are correctly added
2. Check if the certificate validation is complete
3. Ensure that you have ownership of the domain
4. Contact your DNS provider if you're having trouble adding the records