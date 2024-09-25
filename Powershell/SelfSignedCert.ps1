$CA_CERT_NAME = 'SelfSignedRootCA'
$CA_Thumbprint = 'C80AD7A4463AFC16DC36FCB8C17C8C06495C957D'

$APPLICATION = ''  # Example: "myapp"
$ENVIONMENT = ''   # Example: "dev" (leave blank if not applicable)
$DOMAIN = 'kp-development.com' # Default domain


# Ensure location exists
$CA_CERT_TEMP_LOC = "C:\certificates"

# Logic to create the DNS name dynamically
function Construct-DnsName {
    param (
        [string]$application,
        [string]$environment,
        [string]$domain
    )

    # Construct the DNS name dynamically based on the input parameters
    $dnsName = ""

    if (-not [string]::IsNullOrEmpty($application)) {
        $dnsName = $application
    }

    if (-not [string]::IsNullOrEmpty($environment)) {
        if (-not [string]::IsNullOrEmpty($dnsName)) {
            $dnsName += "."  # Add a period if application name exists
        }
        $dnsName += $environment
    }

    if (-not [string]::IsNullOrEmpty($domain)) {
        if (-not [string]::IsNullOrEmpty($dnsName)) {
            $dnsName += "."  # Add a period if any part of the name exists
        }
        $dnsName += $domain
    }

    return $dnsName
}

# Construct the certificate names dynamically
$CERTS_TO_CREATE = @(
    Construct-DnsName -application $APPLICATION -environment $ENVIONMENT -domain $DOMAIN
)

# Remove any empty entries from the array
$CERTS_TO_CREATE = $CERTS_TO_CREATE | Where-Object { -not [string]::IsNullOrEmpty($_) }

Write-Host "Certificates to create:" -ForegroundColor Cyan
$CERTS_TO_CREATE

# Example output, based on input values
# If $APPLICATION = 'myapp', $ENVIONMENT = 'dev', and $DOMAIN = 'kp-development.com',
# the output will be 'myapp.dev.kp-development.com'
# If $ENVIONMENT is empty, the output will be 'myapp.kp-development.com'

# (Rest of the script remains the same)

# Find or create the root CA certificate
$rootca = Get-ChildItem cert:\CurrentUser\my | Where-Object { $_.Thumbprint -eq $CA_Thumbprint }
if ($null -eq $rootca) {

    Write-Host "Creating CA Certificate $($CA_CERT_NAME) ..." -ForegroundColor Green

    $rootcert = New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -DnsName $CA_CERT_NAME -KeyUsage CertSign -NotAfter (Get-Date).AddYears(10)

    Write-Host "CA Certificate Thumbprint: $($rootcert.Thumbprint)"
    $CA_Thumbprint = $rootcert.Thumbprint

    # Export and install root CA certificate to Trusted Root Authorities
    Export-Certificate -Cert $rootcert -FilePath "$($CA_CERT_TEMP_LOC)\$($CA_CERT_NAME).cer"

    # Import root certificate to Trusted Root (requires Admin privileges)
    Import-Certificate -FilePath "$($CA_CERT_TEMP_LOC)\$($CA_CERT_NAME).cer" -CertStoreLocation Cert:\LocalMachine\Root

    $rootca = $rootcert
} else {
    Write-Host "CA Certificate already exists: $($CA_CERT_NAME)" -ForegroundColor Yellow
    Write-Host "CA Certificate Thumbprint: $($rootca.Thumbprint)"
}

# Create certificates signed by the root CA
foreach ($CERT_NAME in $CERTS_TO_CREATE) {
    Write-Host "Creating certificate for $CERT_NAME" -ForegroundColor Green
    New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $CERT_NAME -FriendlyName $CERT_NAME `
        -Signer $rootca -NotAfter (Get-Date).AddYears(5)
}
