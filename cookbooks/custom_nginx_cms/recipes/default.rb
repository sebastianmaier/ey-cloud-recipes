#
# Cookbook Name:: custom_nginx_cms
# Recipe:: default
#
Chef::Log.info "should update nginx.conf"
if ['app_master','app'].include?(node[:instance_role])
	if File.exist?("/etc/nginx/nginx.conf")
		execute "update nginx.conf" do
		  command "sed -i -e 's/include \/etc\/nginx\/servers\/\*\.conf;/ \
					 include \/etc\/nginx\/servers\/cms\.conf; \
					 include \/etc\/nginx\/servers\/cms_beta\.conf; \
					 /g' /data/nginx/nginx.conf"
		  contents = File.read('/etc/nginx/nginx.conf')					 
		  Chef::Log.info contents
		  Chef::Log.info "hopefuly updated nginx.conf"
		  command "/etc/init.d/nginx restart"
		end
	end
end