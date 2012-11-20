#
# Cookbook Name:: custom_nginx_cms
# Recipe:: default
#
Chef::Log.info "should update nginx.conf"
if ['app_master','app'].include?(node[:instance_role])
	if File.exist?("/data/nginx/nginx.conf")
		execute "update nginx.conf" do
		  command "sed -i -e 's/include \/etc\/nginx\/servers\/\*\.conf;/ test123 /g' /data/nginx/nginx.conf"
		  Chef::Log.info returns
		  contents = File.read('/data/nginx/nginx.conf')					 
		  Chef::Log.info contents
		  command "/etc/init.d/nginx restart"
		  action :run
		end
	end
end