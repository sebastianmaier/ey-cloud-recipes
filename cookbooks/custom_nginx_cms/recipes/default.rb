#
# Cookbook Name:: custom_nginx_cms
# Recipe:: default
#
Chef::Log.info "should update nginx.conf"
if ['app_master','app'].include?(node[:instance_role])
	if File.exist?("/data/nginx/nginx.conf")
		execute "update nginx.conf" do
		  #command "sed -i -e 's/include \/etc\/nginx\/servers\/\*\.conf;/ test123 /g' /data/nginx/nginx.conf"
		  contents = File.read('/data/nginx/nginx.conf')
		  result = contents.gsub(/include \/etc\/nginx\/servers\/\*\.conf;/, "include /etc/nginx/servers/cms.conf;\ninclude /etc/nginx/servers/cms_beta.conf; ")					 
		    begin
			  file = File.open("/data/nginx/nginx.conf", "w")
			  file.write(result) 
			rescue IOError => e
			  #some error occur, dir not writable etc.
			ensure
			  file.close unless file == nil
			end
		  Chef::Log.info result
		  command "/etc/init.d/nginx restart"
		  action :run
		end
	end
end