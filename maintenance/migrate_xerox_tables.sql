

pg_dump -Fc --no-acl --no-owner -h localhost -U rfengine -t xerox_copiers fv_production_snapshot > xerox_copiers.dump
pg_dump -Fc --no-acl --no-owner -h localhost -U rfengine -t billing_invoices fv_production_snapshot > billing_invoices.dump
pg_dump -Fc --no-acl --no-owner -h localhost -U rfengine -t billing_invoice_line_items fv_production_snapshot > billing_invoice_line_items.dump
pg_dump -Fc --no-acl --no-owner -h localhost -U rfengine -t fb_clients fv_production_snapshot > fb_clients.dump





heroku pgbackups:restore GRAY 'https://s3.amazonaws.com/rf-docs-production/dbtransfer/xerox_copiers.dump'
heroku pgbackups:restore GRAY 'https://s3.amazonaws.com/rf-docs-production/dbtransfer/billing_invoices.dump'
heroku pgbackups:restore GRAY 'https://s3.amazonaws.com/rf-docs-production/dbtransfer/billing_invoice_line_items.dump'
heroku pgbackups:restore GRAY 'https://s3.amazonaws.com/rf-docs-production/dbtransfer/fb_clients.dump'



update xerox_copiers set user_id = 119 where user_id = 6;
update billing_invoices set site_account_id = 242  where site_account_id = 3;
update fb_clients set user_id = 119 where user_id = 6;
