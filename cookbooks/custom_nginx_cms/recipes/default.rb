#
# Cookbook Name:: custom_nginx_cms
# Recipe:: default
#
if File.exist?("/etc/nginx/nginx.conf")
	execute "update nginx.conf" do
	  command "sed -i -e 's/include \/etc\/nginx\/servers\/\*\.conf;/ \
				 include \/etc\/nginx\/servers\/cms\.conf; \
				 include \/etc\/nginx\/servers\/cms_beta\.conf; \
				 /g' nginx.conf"
	  command "/etc/init.d/nginx restart"
	end
end