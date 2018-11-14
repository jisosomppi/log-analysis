# Automate generation of local repository
# Forces Salt to keep packages at chosen version
# Usage: Save this script, chmod u+x to make it usable

# Install prerequisites
apt-get update
apt-get install -y dpkg-dev

# Make folder for local repository
mkdir /srv/local-repo
cd /srv/local-repo

# Download packages (6.4.2 for plugin compatibility)
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.deb
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.4.2-amd64.deb
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.4.2.deb

# Create repo
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
echo "deb file:/srv/local-repo ./" | tee -a /etc/apt/sources.list

# Manual install DEPRECATED
# Use Salt states instead
#apt-get update
#apt-get install -y elasticsearch kibana logstash --allow-unauthenticated
