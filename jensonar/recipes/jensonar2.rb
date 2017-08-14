#2nd PART 

execute 'jenjar' do
  command 'cd /mnt/ && wget http://localhost:8080/jnlpJars/jenkins-cli.jar'
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