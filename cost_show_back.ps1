# Import the ImportExcel module (ensure it's installed first)
Import-Module ImportExcel

# Import the table from an Excel file
# Ensure the Excel file has columns: ComputerName, IsVirtual, Function
$inputTable = Import-Excel -Path "C:\Path\To\Your\Input\File.xlsx" -WorksheetName "Sheet1"

# Define the Get-SupportCharges function
Function Get-SupportCharges {
    param([PSCustomObject]$box)

    $chargelist = @()
    Function New-Charge {
        param(
            [string]$ChargeType,
            [double]$Amount,
            [string]$Function
        )
        return ([PSCustomObject]([ordered]@{
                    ChargeType = $ChargeType
                    Amount     = [math]::Round($Amount, 2)
                    Function   = $Function
                }))
    }

    # Base charges for virtual systems
    if ($box.IsVirtual -eq $true) {
        $chargelist += New-Charge -ChargeType "DC Cost" -Amount 10.0 -Function "Base"
        $chargelist += New-Charge -ChargeType "EC Windows Support" -Amount 10.0 -Function "Base"
        $chargelist += New-Charge -ChargeType "Windows Licensing" -Amount 50.0 -Function "Base"
    }
    else {

        # Base charges for physical systems
        if ($box.Function -eq 'HyperV-Server') {
            $chargelist += New-Charge -ChargeType "DC Cost" -Amount 125.0 -Function "Base"
        }
        else {
            $chargelist += New-Charge -ChargeType "DC Cost" -Amount 100.0 -Function "Base"
        }
        $chargelist += New-Charge -ChargeType "EC Windows Support" -Amount 50.0 -Function "Base"

        # Additional DC cost for physical systems
        $chargelist += New-Charge -ChargeType "DC Cost" -Amount 10.0 -Function "Base"
    }

    # Middleware cost for all systems
    $chargelist += New-Charge -ChargeType "Management Software" -Amount 50.0 -Function "Middleware"

    # FLS charges (conditional section)
    if ($box.Function -eq 'NTFS-Server') {
        $chargelist += New-Charge -ChargeType "FLS" -Amount 20.0 -Function "FLS"
    }

    # IIS charges (conditional section)
    if ($box.Function -eq 'WWW-Server') {
        $chargelist += New-Charge -ChargeType "IIS" -Amount 15.0 -Function "IIS"
    }

    # SQL charges (conditional section)
    if ($box.Function -eq 'MSSQL-Server') {
        $chargelist += New-Charge -ChargeType "SQL" -Amount 100.0 -Function "SQL"
    }

    # Calculate total charges
    $totalCharges = 0
    Foreach ($charge in $chargelist.Amount) {
        $totalCharges += $charge
    }

    # Return the result
    return ([PSCustomObject]([ordered]@{
                ComputerName = $box.ComputerName
                IsVirtual    = $box.IsVirtual
                Function     = $box.Function
                ChargeList   = ($chargelist | Out-String).Trim() # Convert ChargeList to a readable string
                TotalCharges = $totalCharges
            }))
}

# Process each row in the imported table
$resultArray = $inputTable | ForEach-Object {
    # Convert Excel row to a PSCustomObject and pass it to Get-SupportCharges
    Get-SupportCharges -box $_
}

# Export the results to a new Excel file
$resultArray | Export-Excel -Path "C:\Path\To\Your\Output\File.xlsx" -WorksheetName "Results" -AutoSize
