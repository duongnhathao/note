#!/bin/bash
if [[ $USER != "root" ]]; then
    echo "This script must be run as root"
    exit
fi

is_install=0
port=80

while getopts i:h:p:d:g:t: flag; do
    case "${flag}" in
    i) is_install=${OPTARG} ;;
    h) domain=${OPTARG} ;;
    p) port=${OPTARG} ;;
    g) git=${OPTARG} ;;
    d) dir_project=${OPTARG} ;;
    t) type_source=${OPTARG} ;;
    *) ;;
    esac
done

if [ "$port" -eq 443 ]; then
    port=80
fi
if [ "$is_install" -eq 1 ]; then
    sudo apt -y update
    sudo apt -y install nginx
    clear
fi
systemctl -q is-active nginx && echo "Nginx is active"

if [ -z "$dir_project" ]; then
    dir_project="$domain"
else
    dir_project="/var/www/$dir_project"
fi

if [ -n "$git" ]; then
    git clone --quiet "$git" "$dir_project" || exit 1
    cd "$dir_project" || (echo "not_found_dir" && exit)
    mkdir vendor
    composer install
    cp .env.example .env
    chown -R www-data:www-data "$dir_project"
    chmod -R 755 "$dir_project"
    echo "clone into $dir_project"
fi

if [ "$type_source" == "laravel" ]; then
    dir_project="$dir_project/public"
fi

if [ -n "$domain" ]; then
    echo "setup for $domain"
    domain_file_content="
    server {
        listen [::]:$port;
        listen $port;

        # allow upload file with size upto 500MB
        client_max_body_size 500M;
        root $dir_project;
        index index.php index.html index.htm;
        server_name $domain www.$domain;

        charset utf-8;

            location / {
                try_files \$uri \$uri/ /index.php?\$query_string;
            }

            location = /favicon.ico { access_log off; log_not_found off; }
            location = /robots.txt  { access_log off; log_not_found off; }

            error_page 404 /index.php;

            location ~ \.php$ {
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
                include fastcgi_params;
            }

            location ~ /\.(?!well-known).* {
                deny all;
            }
    }"
    echo "$domain_file_content" >>"/etc/nginx/sites-available/$domain"
    cp "/etc/nginx/sites-available/$domain" "/etc/nginx/sites-enabled/"
    value=$(cat /etc/nginx/sites-enabled/"$domain")
    if [[ -n "$value" ]]; then
        echo "file add success"
    else
        echo "failed add file"
    fi
    nginx -t
    systemctl reload nginx

else
    echo "not_found_domain_name"
fi
