# AK Smart Home Device Simulator

This simulator allows you to create virtual smart home devices that connect to your AWS IoT Core backend. It's useful for testing your AK Smart Home Platform without physical hardware.

## Setup

1. Install dependencies:
   ```
   npm install
   ```

2. Create a `certs` directory and add your device certificates:
   ```
   mkdir certs
   ```

3. Copy the following files to the `certs` directory:
   - `private.key`: Your device private key
   - `certificate.pem.crt`: Your device certificate
   - `AmazonRootCA1.pem`: Amazon Root CA certificate

4. Create a `.env` file with your IoT endpoint:
   ```
   cp .env.example .env
   ```

5. Edit the `.env` file and set your IoT endpoint:
   ```
   IOT_ENDPOINT=xxxxxxxxxx-ats.iot.us-east-1.amazonaws.com
   ```

## Creating Device Certificates

To create device certificates:

1. Go to the AWS IoT Core console
2. Navigate to "Secure" > "Certificates"
3. Click "Create" to create a new certificate
4. Download the certificate, private key, and Amazon Root CA
5. Activate the certificate
6. Attach the AKSmartHomeDevicePolicy to the certificate

## Running the Simulator

### Basic Usage

```
node index.js --type light --name "Living Room Light" --location "Living Room"
```

### Available Device Types

- `light`: Simulates a smart light with power, brightness, and color temperature controls
- `thermostat`: Simulates a smart thermostat with temperature, target temperature, mode, and humidity
- `switch`: Simulates a simple smart switch with power control

### Command Line Options

- `--type`, `-t`: Device type (light, thermostat, switch)
- `--name`, `-n`: Device name
- `--id`, `-i`: Device ID (will be generated if not provided)
- `--location`, `-l`: Device location
- `--cert-dir`, `-c`: Directory containing certificates (default: ./certs)

### Predefined Scripts

You can use the predefined npm scripts:

```
npm run simulate-light
npm run simulate-thermostat
npm run simulate-switch
```

## Device Capabilities

### Light
- Power (on/off)
- Brightness (0-100%)
- Color Temperature (2700K-6500K)

### Thermostat
- Temperature (current temperature)
- Target Temperature (desired temperature)
- Mode (heat, cool, auto, off)
- Humidity (current humidity %)

### Switch
- Power (on/off)

## Testing Commands

You can send commands to the device using the AWS IoT Core MQTT test client:

1. Go to the AWS IoT Core console
2. Navigate to "Test" > "MQTT test client"
3. Subscribe to `device/+/state` to see all device states
4. Publish to `device/{deviceId}/command` with a payload like:

```json
{
  "command": "power",
  "value": true,
  "timestamp": "2023-05-01T12:00:00Z",
  "requestId": "request123"
}
```

## Troubleshooting

### Connection Issues
- Verify your certificates are correct and activated
- Check that the IoT endpoint is correct
- Ensure the device policy allows the necessary MQTT actions
- Check that your AWS credentials have IoT permissions

### Command Not Working
- Verify the command topic format: `device/{deviceId}/command`
- Check that the command payload is valid JSON
- Ensure the command is supported by the device type