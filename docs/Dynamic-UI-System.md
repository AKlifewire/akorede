# AK Smart Home Platform - Dynamic UI System

This guide explains the dynamic UI system that automatically adapts to different device capabilities.

## Overview

The AK Smart Home Platform uses a component-based UI system that dynamically renders the interface based on the capabilities of each device. This allows the app to automatically display the appropriate controls and visualizations for any device, regardless of its configuration.

## Architecture

The dynamic UI system consists of the following components:

1. **Component Registry**: A DynamoDB table that stores UI component definitions
2. **Device Registry**: A DynamoDB table that stores device capabilities
3. **UI Generator**: A Lambda function that generates dynamic UI based on device capabilities
4. **UI Bucket**: An S3 bucket that stores UI templates and generated UIs

## How It Works

1. When a user opens the app, it fetches the list of devices associated with their account
2. For each device, the app requests a UI from the backend
3. The UI Generator Lambda function:
   - Retrieves the device information from the Device Registry
   - Gets the appropriate UI components based on the device's capabilities
   - Merges the components with a base template
   - Returns a complete UI definition
4. The app renders the UI according to the definition

## Component Types

The system supports various component types:

1. **Controls**: Interactive elements like switches, sliders, and buttons
2. **Displays**: Visualization elements like gauges, charts, and status indicators
3. **Sections**: Container elements that group related controls and displays

## Example: Multi-Relay Device

For a device with multiple relays:

1. The device registers with capabilities: `["relay", "relay", "relay", "relay"]`
2. Each relay is identified by a unique ID (e.g., "relay1", "relay2", etc.)
3. The UI Generator fetches the "relay-control" component for each relay
4. The component is instantiated with the appropriate relay ID and name
5. The app renders a switch for each relay

## Example: Temperature Sensor

For a temperature sensor:

1. The device registers with capability: `["temperature"]`
2. The UI Generator fetches the "temperature-display" component
3. The component is configured to display the current temperature and history
4. The app renders a temperature card with value and chart

## Adding New Device Types

To add support for a new device type:

1. Create component definitions in the Component Registry
2. Create UI templates in the UI Bucket
3. Update the device registration process to include the new capabilities

No code changes are required in the app or backend to support new device types.

## Component Definition Format

Component definitions use the following format:

```json
{
  "componentType": "control|display|section",
  "componentId": "unique-id",
  "deviceType": "device-type",
  "capability": "capability-name",
  "version": "1.0",
  "uiControl": {
    // Control definition
  },
  "uiSection": {
    // Section definition
  },
  "metadata": {
    "description": "Component description",
    "author": "Author name",
    "created": "Creation date"
  }
}
```

## Template Variables

Templates support variable substitution using the `{{variable}}` syntax:

- `{{deviceId}}`: The ID of the device
- `{{state.property}}`: A property from the device state
- `{{deviceInfo.property}}`: A property from the device information
- `{{metadata.property}}`: A property from the metadata

## Security Considerations

- All UI definitions are validated before rendering
- The app enforces access control to ensure users can only access their own devices
- Templates are versioned to support rollbacks

## Best Practices

1. **Component Reusability**: Design components to be reusable across different device types
2. **Progressive Enhancement**: Design UIs to work with minimal capabilities and enhance as more are available
3. **Responsive Design**: Ensure components adapt to different screen sizes
4. **Offline Support**: Cache UI definitions for offline use
5. **Version Control**: Use versioning for components and templates

## Resources

- [Component Registry Schema](./component-registry-schema.md)
- [UI Template Reference](./ui-template-reference.md)
- [Adding Custom Components](./adding-custom-components.md)