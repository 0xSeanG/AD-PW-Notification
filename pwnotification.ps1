##################################################################################################################
# Please Configure the following variables....
$smtpServer="Company Email Server"
$expireindays = 14
$from = "Email address you want reminders to come from"
###################################################################################################################

#Get Users From AD who are enabled
Import-Module ActiveDirectory
$users = get-aduser -filter * -properties * |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }

foreach ($user in $users)
{
  $Name = (Get-ADUser $user | foreach { $_.Name})
  $emailaddress = $user.emailaddress
  $passwordSetDate = (get-aduser $user -properties * | foreach { $_.PasswordLastSet })
  $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
  # Check for Fine Grained Password
  if (($PasswordPol) -ne $null)
  {
    $maxPasswordAge = ($PasswordPol).MaxPasswordAge
  }
  
  else
  {
    $maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
  }
  
  
  $expireson = $passwordsetdate + $maxPasswordAge
  $today = (get-date)
  $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
  $subject="REMINDER: Your Password Expires in $daystoExpire days"
  $body ="
  Dear $name,
  <p> Just a friendly reminder that your Domain password expires in $daystoexpire days.<br><br>

  <b>Company email message to the user.</b><br><br>

  <p>Thank you, <br> 
<b>Company's IT Dept.<b>
  </P>"
  
  if ($daystoexpire -lt $expireindays)
  {
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High
     
  }  
   
}
