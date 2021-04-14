# wealthfront-tax-info-exporter

Export all transactions (including dividends) details into a CSV file

## Instructions

1. Login & visit [https://www.wealthfront.com/transactions](https://www.wealthfront.com/transactions)
1. Start the web inspector and start tracking network requests
1. Clear web requests
1. Select `Past Year`
1. Filter `XHR` requests
1. Look for the new `transfers-for-account` request
1. Copy the `Response` and save it into `wealthfront.json` in this directory
1. Run `generate_tax_documents.rb`

## Resulting CSV files

<img src="/assets/csv-screenshot-1" width="400" />
<img src="/assets/csv-screenshot-2" width="400" />

## Wealthfront UI the data is fetched from

<img src="/assets/wf-screenshot-1" width="400" />
<img src="/assets/wf-screenshot-2" width="400" />
<img src="/assets/wf-screenshot-3" width="400" />
