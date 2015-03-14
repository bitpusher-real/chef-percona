#
# Cookbook Name:: percona
# Recipe:: package_repo
#

return unless node["percona"]["use_percona_repos"]

case node["platform_family"]
when "debian"
  include_recipe "apt"

  # Pin this repo as to avoid upgrade conflicts with distribution repos.
  apt_preference "00percona" do
    glob "*"
    pin "release o=Percona Development Team"
    pin_priority "1001"
  end

  apt_repository "percona" do
    uri node["percona"]["apt_uri"]
    distribution node["lsb"]["codename"]
    components ["main"]
    keyserver node["percona"]["apt_keyserver"]
    key node["percona"]["apt_key"]
    action :add
  end

when "rhel"
  include_recipe "yum"

  # Be backwards-compatible with versions of the yum cookbook <3.0
  if run_context.cookbook_collection['yum'].metadata.version.to_i < 3
    arch = node['kernel']['machine'] == "x86_64" ? "x86_64" : "i386"
    pversion = node['platform_version'].to_i

    yum_key "RPM-GPG-KEY-percona" do
      url "http://www.percona.com/downloads/RPM-GPG-KEY-percona"
      action :add
    end

    yum_repository "percona" do
      repo_name "Percona"
      description "Percona Repo"
      url "http://repo.percona.com/centos/#{pversion}/os/#{arch}/"
      key "RPM-GPG-KEY-percona"
      action :add
    end
  else
    yum_repository "percona" do
      description node["percona"]["yum"]["description"]
      baseurl node["percona"]["yum"]["baseurl"]
      gpgkey node["percona"]["yum"]["gpgkey"]
      gpgcheck node["percona"]["yum"]["gpgcheck"]
      sslverify node["percona"]["yum"]["sslverify"]
      action :create
    end
  end
end
