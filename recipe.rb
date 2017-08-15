execute "update yum repo" do
  user "root"
  command "yum -y update"
end

package "epel-release"
package "gcc"
package "openssl-devel"
package "libyaml-devel"
package "readline-devel"
package "zlib-devel"
package "git"


#ダウンロード　yum -y install wget git ImageMagick ImageMagick-devel
execute "Download Tools" do
  user "root"
  command "yum -y install wget git ImageMagick ImageMagick-devel gcc-c++"
end


# vi /etc/ImageMagick/policy.xml
remote_file "/etc/ImageMagick/policy.xml" do
  user "root"
  owner "root"
  group "root"
  source "policy.xml"
end

remote_file "/etc/yum.repos.d/mongodb-org-3.4.repo" do
  user "root"
  owner "root"
  group "root"
  source "mongodb-org-3.4.repo"
end

execute "install mongodb" do
  user "root"
  command "yum install -y --enablerepo=mongodb-org-3.4 mongodb-org"
end

service 'mongod' do
  user "root"
  action [:enable, :start]
end

user "create user" do
  user "root"
  username "shirasagi"
  password "password_shirasagi"
end

# execute "install rbenv&ruby"
RBENV_DIR = "/usr/local/rbenv"
RBENV_SCRIPT = "/etc/profile.d/rbenv.sh"

git RBENV_DIR do
  repository "git://github.com/sstephenson/rbenv.git"
end

remote_file RBENV_SCRIPT do
  source "remote_files/rbenv.sh"
end

execute "set owner and mode for #{RBENV_SCRIPT} " do
  command "chown root: #{RBENV_SCRIPT}; chmod 644 #{RBENV_SCRIPT}"
  user "root"
end

execute "mkdir #{RBENV_DIR}/plugins" do
  not_if "test -d #{RBENV_DIR}/plugins"
end

git "#{RBENV_DIR}/plugins/ruby-build" do
  repository "git://github.com/sstephenson/ruby-build.git"
end

node["rbenv"]["versions"].each do |version|
  execute "install ruby #{version}" do
    command "source #{RBENV_SCRIPT}; rbenv install #{version}"
    not_if "source #{RBENV_SCRIPT}; rbenv versions | grep #{version}"
  end
end

execute "set global ruby #{node["rbenv"]["global"]}" do
  command "source #{RBENV_SCRIPT}; rbenv global #{node["rbenv"]["global"]}; rbenv rehash"
  not_if "source #{RBENV_SCRIPT}; rbenv global | grep #{node["rbenv"]["global"]}"
end

node["rbenv"]["gems"].each do |gem|
  execute "gem install #{gem}" do
    command "source #{RBENV_SCRIPT}; gem install #{gem}; rbenv rehash"
    not_if "source #{RBENV_SCRIPT}; gem list | grep #{gem}"
  end
end

#git clone shirasagi stable
git "/var/www/shirasagi" do
  user "root"
  repository "git://github.com/shirasagi/shirasagi.git"
end

execute "Copy config files" do
  cwd "/var/www/shirasagi"
  command "cp -n config/samples/*.{rb,yml} config/"
end
