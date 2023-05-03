Param(
   [Parameter(Mandatory=$true)]
   [ValidateSet('npm','yarn','pnpm', ErrorMessage = 'Must provide node.js package manager')]
   [string]$package_manager
)

git clone 'https://github.com/wix/import-cost.git'
if (-not $?) {
   Write-Host 'Failed to clone wix/import-cost' -ForegroundColor Red
   exit 1
}

cd import-cost
if (-not $?) { exit 1 }
iex "$package_manager install"
cd ..

cp .\index.js .\import-cost\index.js

