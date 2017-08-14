remote_file "/mnt/jenkins-cli.jar" do
  source "http://localhost:8080/jnlpJars/jenkins-cli.jar"
  mode '0777'
  action :create
end

execute 'gitplugin' do
  command 'cd /mnt/ && java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin github'
end

execute 'sonarplugin' do
  command 'cd /mnt/ && java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin sonar'
end

execute 'reconfigure' do
  command 'cd /mnt/ && java -jar jenkins-cli.jar -s http://localhost:8080/ reload-configuration'
end

service "jenkins" do
  action :restart
end