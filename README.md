# Fluent::Plugin::GeoIP2Filter

This is a [Fluentd](http://fluentd.org/) filter plugin for adding [GeoIP data](http://dev.maxmind.com/geoip/geoip2/geolite2/) to record. Supports the new Maxmind v2 database formats.

## Installation

Install it yourself as:

```
$ gem install fluent-plugin-filter-geoip2
```

## How to build

```
$ gem install bundler
$ bundle install
$ rake test
$ rake build
$ rake install
```

## Config parameters

### enable_auto_download

If true, enable to download GeoIP2 database autometically (default: true).

```
enable_auto_download true
```

### md5_url

GeoIP2 MD5 checksum URL (default: http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz.md5)

```
md5_url http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz.md5
```

### download_url

GeoIP2 database download URL (default: http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz).

```
download_url http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
```

### md5_path

GeoIP2 MD5 checksum path. (default: ./geoip/database/GeoLite2-City.md5)

```
md5_path ./geoip/database/GeoLite2-City.md5
```

### database_path

GeoIP2 database path. (default: ./geoip/database/GeoLite2-City.md5)

```
database_path ./geoip/database/GeoLite2-City.mmdb
```

### md5_asn_url

GeoIP2 MD5 checksum URL (default: http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz.md5)

```
md5_asn_url http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz.md5
```

### download_asn_url

GeoIP2 database download URL (default: http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz).

```
download_asn_url http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz
```

### md5_asn_path

GeoIP2 MD5 checksum path. (default: ./geoip/database/GeoLite2-ASN.md5)

```
md5_asn_path ./geoip/database/GeoLite2-ASN.md5
```

### database_asn_path

GeoIP2 database path. (default: ./geoip/database/GeoLite2-ASN.mmdb)

```
database_asn_path ./geoip/database/GeoLite2-ASN.mmdb
```

### lookup_field

Specify the field name that IP address is stored (default: ip).

```
lookup_field host
```

### output_field

Specify the field name that store the result (default: geoip).

```
output_field geoip
```

### field_delimiter

Specify the field delimiter (default .).

```
field_delimiter .
```

### flatten

If true, to flatten the result using field_delimiter (default: false).

```
flatten false
```

### locale

Get the data for the specified locale (default: en).

```
locale en
```

### continent

If true, to get continent information (default: true).

```
continent true
```

### country

If true, to get country information (default: true).

```
country true
```

### city

If true, to get city information (default: true).

```
city true
```

### location

If true, to get location information (default: true).

```
location true
```

### postal

If true, to get postal information (default: fasle).

```
postal false
```

### registered_country

If true, to get registered country information (default: false).

```
registered_country false
```

### represented_country

If true, to get represented country information (default: false).

```
represented_country false
```

### subdivisions

If true, to get subdivisions information (default: false).

```
subdivisions false
```

### traits

If true, to get traits information (default: false).

```
traits false
```

### connection_type

If true, to get connection type information (default: false).

```
connection_type false
```

### Autonomous System

Autonomous System (default: true).

```
autonomous_system true
```


## Plugin setup examples

```
<filter tail.log>
  @type geoip2

  enable_auto_download true

  lookup_field clientip
  output_field geoip
  field_delimiter .
  flatten false

  locale en
</filter>
```

Assuming following inputs are coming:

```javascript
{
  "clientip": "200.114.49.218"
}
```

then output bocomes as belows:

```javascript
{
  "ufw_ips": "106.154.25.44",
  "geoip": {
    "continent": {
      "code": "AS",
      "geoname_id": 6255147,
      "name": "Asia"
    },
    "country": {
      "geoname_id": 1861060,
      "iso_code": "JP",
      "name": "Japan"
    },
    "location": {
      "latitude": 35.69,
      "longitude": 139.69,
      "time_zone": "Asia/Tokyo"
    },
    "autonomous_system": {
      "number": 2516,
      "organization": "KDDI CORPORATION"
    }
  }
}
```


## Example command

Start fluentd using example fluent.conf.

```
$ fluentd -c ~/github/fluent-plugin-filter-geoip/fluent.conf
2017-03-13 15:11:31 +0900 [info]: reading config file path="/Users/mosuka/github/fluent-plugin-filter-geoip/fluent.conf"
2017-03-13 15:11:31 +0900 [info]: starting fluentd-0.12.33
2017-03-13 15:11:31 +0900 [info]: gem 'fluent-plugin-filter-geoip' version '0.0.1'
2017-03-13 15:11:31 +0900 [info]: gem 'fluent-plugin-grok-parser' version '1.0.0'
2017-03-13 15:11:31 +0900 [info]: gem 'fluent-plugin-output-solr' version '0.4.0'
2017-03-13 15:11:31 +0900 [info]: gem 'fluent-plugin-ua-parser' version '1.1.0'
2017-03-13 15:11:31 +0900 [info]: gem 'fluentd' version '0.12.33'
2017-03-13 15:11:31 +0900 [info]: gem 'fluentd' version '0.12.32'
2017-03-13 15:11:31 +0900 [info]: adding filter pattern="messages" type="geoip"
2017-03-13 15:11:31 +0900 [info]: Current MD5: cc1f9a6f7def282bc33cb477f3379d9f
2017-03-13 15:11:31 +0900 [info]: Fetched MD5: cc1f9a6f7def282bc33cb477f3379d9f
2017-03-13 15:11:32 +0900 [info]: adding match pattern="messages" type="stdout"
2017-03-13 15:11:32 +0900 [info]: adding source type="forward"
2017-03-13 15:11:32 +0900 [info]: using configuration file: <ROOT>
  <source>
    @type forward
    port 24224
  </source>
  <filter messages>
    @type geoip
    enable_auto_download true
    lookup_field clientip
    output_field geoip
    field_delimiter .
    flatten false
    locale en
  </filter>
  <match messages>
    type stdout
  </match>
</ROOT>
2017-03-13 15:11:32 +0900 [info]: listening fluent socket on 0.0.0.0:24224
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mosuka/fluent-plugin-filter-geoip.
