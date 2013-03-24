##
# Cookbook Name:: fat-chef
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

backends = search( :node, "chef_environment:prod AND role:fat-chef-be" )
frontends = search( :node, "chef_environment:prod AND role:fat-chef-fe" )

execute "get deb" do
  not_if File.exists?( "/mnt/private-chef_1.2.8.2-1.ubuntu.11.04_amd64.deb" ).to_s
  command "curl -o /mnt/private-chef_1.2.8.2-1.ubuntu.11.04_amd64.deb http://15.185.102.107:8080/private-chef_1.2.8.2-1.ubuntu.11.04_amd64.deb"
end

cookbook_file "/etc/rsyslog.d/60-pchef-nginx.conf" do
  source "pchef-nginx-fatlog.conf"
end

execute "install es" do
  command "dpkg -i /mnt/private-chef_1.2.8.2-1.ubuntu.11.04_amd64.deb"
  not_if("dpkg --list|grep private-chef")
end

directory "/etc/opscode" do
  action :create
  recursive true
end

cookbook_file "/etc/opscode/private-chef-secrets.json" do
  source "secrets"
end

cookbook_file "/opt/opscode/bin/wait-for-rabbit" do
  mode "0755"
  source "wait-for-rabbit"
end

template "/etc/opscode/private-chef.rb" do
  mode "0644"
  owner "root"
  group "root"
  source "private-chef.erb"
  variables({
    :backends => backends,
    :frontends => frontends,
    :backend_ip => "10.5.194.9"
  })
end

#cookbook_file "/etc/opscode/private-chef.rb" do
  #action :delete
#end

#execute "private-chef-ctl reconfigure" do
#  command "private-chef-ctl reconfigure"
#end

