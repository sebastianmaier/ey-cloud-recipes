#
# Cookbook Name:: custom_haproxy_config
# Recipe:: default
#
if File.exist?("/etc/haproxy.cfg")
	execute "update haproxy.cfg" do
	  command "sed -i -e 's/httpclose/http-server-close/' /etc/haproxy.cfg && /etc/init.d/haproxy reload"
	end
end