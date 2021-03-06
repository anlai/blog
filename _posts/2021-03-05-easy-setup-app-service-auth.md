---
layout: post
title: Easy Setup for App Service Authentication
date: 2021-03-05
categories: azure azure-active-directory app-service
---

Apparently I have setup enough Azure App Services that use the integrated Azure Active Directory (AD) authentication, that I needed to create a script for it.  I got lazy clicking through all the prompts and generating new secrets that I just whipped this up.  In order to execute it the only real requirement is having [Az CLI](https://docs.microsoft.com/en-us/cli/azure/) installed.

If you aren't familiar with the Azure App Service integrated authentication, it basically gives you a turn key solution for turning on site wide authentication against an identity provider.  It even makes it relatively simple to configure to accept other social providers.  But in my case, I have a private directory and integrated it with Microsoft logins.

Ordinarily getting these two things configured is pretty straight forward IF your App Service instance is located in your directory.  However in my case I have a primary directory I use for authentication and a secondary that all my apps sit in.  In order to hook up apps to my primary directory, I need to enter the directory information manually (or script it).

## Creating an App Registration

First you'll need to login to Az CLI so that the following commands will work against Azure.

```powershell
az login --tenant yourname.onmicrosoft.com
```

Next you'll need to prepare the scripts that will execute the commands necessary.  Obviously you might want to tweak somethings to fit your needs.

Drop the below json contents into a working directory and call the file `manifest.json`.  This defines an optional claim id_token to be allowed on the app registration.

```json
{
    "idToken": [
        {
            "name": "auth_time",
            "source": null,
            "essential": false
        }
    ]
}
```

The below script will check if your app registration already exists, and if not create a new one.  Then it will generate a new secret.  Note that it won't clean up any secrets, so if you run it more than once you might need to go clean those up.  The values at the top should be modified to fit your needs:

- **name**: Name of your App Service
- **dns**: The subdomain for your App Service (eg. *subdomain*.yourdomain.com)
- **domain**: The domain for your App Service (eg. subdomain.*yourdomain.com*)

```powershell
Set-Variable -name name -value "name"   # Name of the app
Set-Variable -name dns -Value "dnsroot" # Subdomain for the app
Set-Variable -name domain -Value "domain"   # Domain for the app
Set-Variable -name fqdn -Value "https://$dns.$domain.com"   # Custom DNS for app
Set-Variable -name azfqdn -Value "https://$name-$domain.azurewebsites.net"  # Default generated DNS for an app service
Set-Variable -name authEndpoint -Value "/.auth/login/aad/callback"  # App Service AAD auth endpoint

# Check to see if an app reg exists
Set-Variable -name appId -Value (az ad app list --filter "displayName eq '$name'" --query "[0].appId")

if ($appId -eq $null)
{
    Set-Variable -name replyfqdn -value "$fqdn$authEndpoint"
    Set-Variable -name replyazfqdn -value "$azfqdn$authEndpoint"

    # create the app reg and get back the new appId
    Set-Variable -name appId -Value (az ad app create --display-name $name --reply-urls $replyfqdn $replyazfqdn --optional-claims manifest.json --query "appId")

    Write-Host "App Reg created $name ($appId)"
}
else
{
    Write-Host "App Reg found $name ($appId)"
}

# Generate a secret
Set-Variable -Name secretResult -Value (az ad app credential reset --id $appId -o json)
Set-Variable -Name secret -Value ( $secretResult | ConvertFrom-Json )
Set-Variable -Name tenant -Value $secret.tenant
Set-Variable -Name password -Value $secret.password
Set-Variable -Name issuer -Value "https://sts.windows.net/$tenant/v2.0"

Write-Host ""
Write-Host "========================================"
Write-Host "App Id: $appId"
Write-Host "Secret: $password"
Write-Host "Auth: $issuer"
Write-Host "========================================"
Write-Host ""
```

## Configuring an App Service

Now that we have the output from the last script of the App Id, App Secret, and auth endpoint, we need to configure the App Service with this information and turn on authentication.

Assuming the variables defined above, this script will setup the authentication.

```powershell
Set-Variable -Name subscription -Value ""  # subscription id of app service
Set-Variable -Name rg -Value ""  # resource group name of app service

az account set --subscription $subscription

az webapp auth update -g $rg -n $name --enabled true --action LoginWithAzureActiveDirectory --aad-client-id $appId --aad-client-secret $password --aad-token-issuer-url $issuer --subscription $subscription
```