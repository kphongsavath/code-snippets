
$CA_CERT_NAME = 'Self Signed CA';
$ENVIONMENT = '';
$CA_Thumbprint = '';
$DOMAIN = 'kp-development.com';

#Make Sure location exists
$CA_CERT_TEMP_LOC = "D:\certificates"

$CERTS_TO_CREATE = @(
"ledger.$($ENVIONMENT).$($DOMAIN)",
);

if(Text-Path $CA_CERT_TEMP_LOC){
}else{
    New-Item $CA_CERT_TEMP_LOC -ItemType Directory

}


Write-host "Certificates to create" -ForegroundColor Cyan
$CERTS_TO_CREATE 


$rootca = Get-ChildItem cert:\CurrentUser\my | Where-Object {$_.Subject -eq "CN=$($CA_CERT_NAME)"}
if($rootca -eq $null){

Write-host "Creating CA Certificate $($CA_CERT_NAME) ..." -ForegroundColor Green

$rootcert = New-SelfSignedCertificate -CertStoreLocation cert:\CurrentUser\My -DnsName $CA_CERT_NAME -KeyUsage CertSign

Write-host "Certificate Thumbprint: $($rootcert.Thumbprint)"
$CA_Thumbprint =  $rootcert.Thumbprint

#This needs to be added to Trusted Root
Export-Certificate -Cert $rootcert -FilePath "$($CA_CERT_TEMP_LOC)\$($CA_CERT_NAME).cer"

#Imports certificate to Trusted Publishers (Requires "Run as Administrator")
Import-Certificate -FilePath "$($CA_CERT_TEMP_LOC)\$($CA_CERT_NAME).cer" -CertStoreLocation Cert:\LocalMachine\Root

#the thumbprint of need to be changed to your root certificate. 
$rootca = Get-ChildItem cert:\CurrentUser\my | Where-Object {$_.Thumbprint -eq $rootcert.Thumbprint}

}else{

$CA_Thumbprint = $rootca.Thumbprint

Write-host "Certificate With Name Exists: $($CA_CERT_NAME)" -ForegroundColor Yellow
Write-host "Certificate Thumbprint: $($rootca.Thumbprint)"


}


foreach ($CERT_NAME in $CERTS_TO_CREATE)
{
  New-SelfSignedCertificate -certstorelocation cert:\LocalMachine\My -dnsname $CERT_NAME -FriendlyName $CERT_NAME -Signer $rootca -NotAfter $([datetime]::now.AddYears(5))
}


