class sqlwebapp (
  $dbserver      = $::fqdn,
  $dbinstance    = 'MYINSTANCE',
  $dbpass        = 'Azure$123',
  $dbuser        = 'CloudShop',
  $dbname         = 'AdventureWorks2012',
  $iis_site      = 'Default Web Site',
  $docroot       = 'C:/inetpub/wwwroot',
  $file_source   = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
) {

  require sqlwebapp::iis

  file { "${docroot}/CloudShop":
    ensure  => directory,
  }

  archive { 'Unzip webapp CloudShop':
    source       => "${file_source}/CloudShop.zip",
    path         => "${docroot}/CloudShop.zip",
    cleanup      => true,
    extract      => true,
    extract_path => "${docroot}/CloudShop",
    creates      => "${docroot}/CloudShop/Global.asax",
    require      => File["${docroot}/CloudShop"],
    notify       => Exec['ConvertAPP'],
  }

  file { "${docroot}/CloudShop/Web.config":
    ensure  => present,
    content => template("${module_name}/Web.config.erb"),
    require => Archive['Unzip webapp CloudShop'],
  }

  exec { 'ConvertAPP':
    command     => "ConvertTo-WebApplication \'IIS:/Sites/${iis_site}/CloudShop\'",
    provider    => powershell,
    refreshonly => true,
  }
}
