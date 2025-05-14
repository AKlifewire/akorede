# Script to clear CDK lock files and run synth with custom output
param(
    [string]$outputDir = "custom-cdk.out"
)

# Remove any lock files in cdk.out
Write-Host "Removing lock files from cdk.out directory..."
Remove-Item -Path "cdk.out\*.lock" -Force -ErrorAction SilentlyContinue

# Run CDK synth with custom output directory
Write-Host "Running CDK synth with output directory: $outputDir"
npx cdk synth --output $outputDir

Write-Host "Done!"