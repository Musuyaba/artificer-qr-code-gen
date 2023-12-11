test-traefik:
	artillery run --output report_traefik.json load-test.yml && \
	artillery report --output report_traefik.html report_traefik.json 

test-nginx:
	artillery run --output report_nginx.json load-test.yml && \
	artillery report --output report_nginx.html report_nginx.json