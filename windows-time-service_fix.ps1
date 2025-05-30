# Fix Windows Time Service (W32Time) script
# Define the list of machines to operate on, split by newlines, and trim any whitespace
$operateOnThese = "server01
server02
server03
server04".split("`n") | % { $_.trim() }

# Initialize an empty array to store job objects
$jobs = @()

# Define a script block to audit the W32Time service on a remote machine
[scriptblock]$auditblock = {
    $comp = $args[0]  # Get the machine name passed as an argument
    Get-Service -ComputerName $comp -Name W32Time  # Retrieve the W32Time service details
}

# Start a job for each machine to audit the W32Time service
Foreach($machine in $operateOnThese) {
    $jobs += Start-RSJob -ScriptBlock $auditblock -ArgumentList $machine -Name $machine -Batch "JobExecution" -Throttle 45
}

# Initialize an empty array to store the results of the jobs
$results = @()

# Wait for all audit jobs to complete
$jobs | Wait-RSJob

# Collect the results of the completed jobs
$jobs | % { $results += Receive-RSJob -Job $_ }

# Filter the results to find machines where the W32Time service is not set to 'Automatic'
$touchthese = $results | ? { $_.StartType -ne 'Automatic' }

# Define a script block to fix the W32Time service on a remote machine
[scriptblock]$fixblock = {
    $comp = $args[0]  # Get the machine name passed as an argument
    Set-Service W32Time -ComputerName $comp -StartupType Automatic  # Set the service to 'Automatic'
    Get-Service -ComputerName $comp -Name W32Time | Start-Service  # Start the service
}

# Initialize an empty array to store job objects for fixing the service
$fixjobs = @()

# Start a job for each machine that needs the W32Time service fixed
Foreach($machine in $touchthese.MachineName) {
    $fixjobs += Start-RSJob -ScriptBlock $fixblock -ArgumentList $machine -Name $machine -Batch "JobExecution" -Throttle 45
}

# Initialize an empty array to store the results of the fix jobs
$fixresults = @()

# Wait for all fix jobs to complete
$fixjobs | Wait-RSJob

# Collect the results of the completed fix jobs
$fixjobs | % { $fixresults += Receive-RSJob -Job $_ }
