# wealthfront-tax-info-exporter

## Dividents

Export all dividends transactions into a CSV file

Wealthfront provides the basic tax documents, however they are geared towards only the US tax system. The exports don't allow you to export all dividends, but only the transactions. With this project, you can easily generate CSV files for all dividends you have received.

### Instructions

1. Login & visit [https://www.wealthfront.com/transactions](https://www.wealthfront.com/transactions)
1. Start the web inspector and start tracking network requests
1. Clear web requests
1. Select `Past Year`
1. Filter `XHR` requests
1. Look for the new `transfers-for-account` request
1. Copy the `Response` and save it into `wealthfront.json` in this directory
1. Run `bundle exec ruby generate_tax_documents.rb`

### Resulting CSV files

<img src="/screenshots/csv-screenshot-1.png" />
<img src="/screenshots/csv-screenshot-2.png" />

### Wealthfront UI the data is fetched from

<img src="/screenshots/wf-screenshot-1.png" width="550" />
<img src="/screenshots/wf-screenshot-2.png" width="550" />
<img src="/screenshots/wf-screenshot-3.png" width="550" />

## Trades & Holdings Snapshot

1. Visit [https://www.wealthfront.com/documents](https://www.wealthfront.com/documents)
1. Select `Personal Investment Account`
1. Select `Statements`
1. Manually download each PDF one by one
1. Store those pdfs in a local folder `./pdfs`
1. Run `bundle exec ruby parse_pdfs.rb`
