#Jenkins and SonarQube Integration
#BY GTA
#AT BINFEX

package %w(epel-release java-1.8.0-openjdk wget net-tools unzip git maven)  do
  action :install
end

remote_file node[:jenkins][:package] do
  source node[:jenkins][:rpm]
  mode '0777'
  action :create
end

remote_file '/mnt/sonarqube.zip' do
  source node[:sonarqube][:zip]
  mode '0777'
  action :create
end

package 'jenkins' do
  source node[:jenkins][:package]
   action :install
end

execute 'path' do
  command 'export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-*"'
  command 'export PATH="$JAVA_HOME/bin:$PATH"'
end

execute 'unzip' do
  command 'unzip sonarqube.zip'
  cwd '/mnt/'
end

directory "/var/lib/jenkins/jobs/" do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

directory "/var/lib/jenkins/jobs/jensonar/" do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

directory "/var/lib/jenkins/users/" do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

directory "/var/lib/jenkins/users/admin/" do
  owner 'root'
  group 'root'
  mode '0777'
  action :create
end

template '/var/lib/jenkins/jobs/jensonar/config.xml' do
  source 'config.erb'
  mode '0777'
  owner 'root'
  group 'root'
end  

template '/var/lib/jenkins/config.xml' do
  source 'config1.erb'
  mode '0777'
  owner 'root'
  group 'root'
end

template '/var/lib/jenkins/users/admin/config.xml' do
  source 'config2.erb'
  mode '0777'
  owner 'root'
  group 'root'
end

template '/etc/sysconfig/jenkins' do
  source 'jenkins.erb'
  mode '0777'
  owner 'root'
  group 'root'
end

template '/var/lib/jenkins/hudson.plugins.sonar.SonarGlobalConfiguration.xml' do
  source 'hudson.plugins.sonar.SonarGlobalConfiguration.xml.erb'
  mode '0777'
  owner 'root'
  group 'root'
end

template '/var/lib/jenkins/hudson.plugins.sonar.SonarRunnerInstallation.xml' do
  source 'hudson.plugins.sonar.SonarRunnerInstallation.xml.erb'
  mode '0777'
  owner 'root'
  group 'root'
end

template '/mnt/sonarqube-5.6.6/conf/sonar.properties' do
  source 'sonar.properties.erb'
  mode '0777'
  owner 'root'
  group 'root'
end

template '/mnt/sonarqube-5.6.6/data/sonar.lock.db' do
  source 'sonar.lock.db.erb'
  mode '0777'
  owner 'root'
  group 'root'
end

service "jenkins" do
  action [ :enable, :start ]
end

execute 'sonar' do
  command 'cd /mnt/sonarqube*/bin/linux-x86-64/ && sh sonar.sh start'
end

remote_file "/mnt/jenkins-cli.jar" do
  source "http://localhost:8080/jnlpJars/jenkins-cli.jar"
  mode '0777'
  action :create
end

execute "install git plugins" do
  command "java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin github"
  cwd "/mnt/"
  timeout 60
  retries 10
  action :run
end

execute "install sonar plugins" do
  command "java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin sonar"
  cwd "/mnt/"
  timeout 60
  retries 10
  action :run
end

execute "re configure" do
  command "java -jar jenkins-cli.jar -s http://localhost:8080/ reload-configuration"
  cwd "/mnt/"
  timeout 60
  retries 10
  action :run
end

service "jenkins" do
  action :restart
end
