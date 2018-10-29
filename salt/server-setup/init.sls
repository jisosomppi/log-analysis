apt-transport-https:
  pkg.installed

default-jdk:
  pkg.installed

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -:
  cmd.run

echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list:
  cmd.run

