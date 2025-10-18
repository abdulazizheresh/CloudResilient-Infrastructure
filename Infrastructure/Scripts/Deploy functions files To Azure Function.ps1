# If you want to Deploy a Backend Js App to Function App
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Firstly, Run it:
cd "C:\Users\USERNAME\Documents\CloudResilient Infrastructure\Backend\functions"

npm install

# And Run it To Publish App:
func azure functionapp publish func-cloudres-centralus-prod --javascript
func azure functionapp publish func-cloudres-northeurope-prod --javascript

# And if you want to Update any Files in Backend/functions, Run it:
cd "C:\Users\USERNAME\Documents\CloudResilient Infrastructure\Backend\functions"

func azure functionapp publish func-cloudres-centralus-prod --javascript
func azure functionapp publish func-cloudres-northeurope-prod --javascript

# To test:

# Test GetInfo
Invoke-RestMethod -Uri "https://func-cloudres-centralus-prod.azurewebsites.net/api/info"
Invoke-RestMethod -Uri "https://func-cloudres-northeurope-prod.azurewebsites.net/api/info"

# Test GetVisitors
Invoke-RestMethod -Uri "https://func-cloudres-centralus-prod.azurewebsites.net/api/visitors"
Invoke-RestMethod -Uri "https://func-cloudres-northeurope-prod.azurewebsites.net/api/visitors"

# Test IncrementVisitor (POST)
Invoke-RestMethod -Uri "https://func-cloudres-centralus-prod.azurewebsites.net/api/increment" -Method POST
Invoke-RestMethod -Uri "https://func-cloudres-northeurope-prod.azurewebsites.net/api/increment" -Method POST