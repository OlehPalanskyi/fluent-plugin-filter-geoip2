require 'maxminddb'
require 'json'
require 'fileutils'
require 'open-uri'
require 'zlib'
require 'fileutils'

module Fluent
  class GeoIP2Filter < Filter
    Fluent::Plugin.register_filter('geoip2', self)

    DEFAULT_ENABLE_DOWNLOAD = true

    DEFAULT_MD5_CITY_URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz.md5'
    DEFAULT_DOWNLOAD_CITY_URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz'
    DEFAULT_MD5_CITY_PATH = './geoip/database/GeoLite2-City.md5'
    DEFAULT_DATABASE_CITY_PATH = './geoip/database/GeoLite2-City.mmdb'

    DEFAULT_MD5_ASN_URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz.md5'
    DEFAULT_DOWNLOAD_ASN_URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz'
    DEFAULT_MD5_ASN_PATH = './geoip/database/GeoLite2-ASN.md5'
    DEFAULT_DATABASE_ASN_PATH = './geoip/database/GeoLite2-ASN.mmdb'

    DEFAULT_LOOKUP_FIELD = 'ip'
    DEFAULT_OUTPU_FIELD = 'geoip'
    DEFAULT_FIELD_DELIMITER = '.'
    DEFAULT_FLATTEN = false

    DEFAULT_LOCALE = 'en'

    DEFAULT_CITY = true
    DEFAULT_CONTINENT = true
    DEFAULT_COUNTRY = true
    DEFAULT_LOCATION = true
    DEFAULT_POSTAL = false
    DEFAULT_REGISTERED_COUNTRY = false
    DEFAULT_REPRESENTED_COUNTRY = false
    DEFAULT_SUBDIVISIONS = false
    DEFAULT_TRAITS = false
    DEFAULT_CONNECTION_TYPE = false
    DEFAULT_AUTONOMOUS_SYSTEM = true

    config_param :enable_auto_download, :bool, :default => DEFAULT_ENABLE_DOWNLOAD,
                 :desc => 'If true, enable to download GeoIP2 database autometically (default: %s).' % DEFAULT_ENABLE_DOWNLOAD

    config_param :md5_city_url, :string, :default => DEFAULT_MD5_CITY_URL,
                 :desc => 'GeoIP2 MD5 checksum URL (default: %s)' % DEFAULT_MD5_CITY_URL

    config_param :download_city_url, :string, :default => DEFAULT_DOWNLOAD_CITY_URL,
                 :desc => 'GeoIP2 database download URL (default: %s).' % DEFAULT_DOWNLOAD_CITY_URL

    config_param :md5_city_path, :string, :default => DEFAULT_MD5_CITY_PATH,
                 :desc => 'GeoIP2 MD5 checksum path. (default: %s)' % DEFAULT_MD5_CITY_PATH

    config_param :database_city_path, :string, :default => DEFAULT_DATABASE_CITY_PATH,
                 :desc => 'GeoIP2 database path. (default: %s)' % DEFAULT_DATABASE_CITY_PATH

    config_param :md5_asn_url, :string, :default => DEFAULT_MD5_ASN_URL,
                 :desc => 'GeoIP2 MD5 checksum URL (default: %s)' % DEFAULT_MD5_ASN_URL

    config_param :download_asn_url, :string, :default => DEFAULT_DOWNLOAD_ASN_URL,
                 :desc => 'GeoIP2 database download URL (default: %s).' % DEFAULT_DOWNLOAD_ASN_URL

    config_param :md5_asn_path, :string, :default => DEFAULT_MD5_ASN_PATH,
                 :desc => 'GeoIP2 MD5 checksum path. (default: %s)' % DEFAULT_MD5_ASN_PATH

    config_param :database_asn_path, :string, :default => DEFAULT_DATABASE_ASN_PATH,
                 :desc => 'GeoIP2 database path. (default: %s)' % DEFAULT_DATABASE_ASN_PATH

    config_param :lookup_field, :string, :default => DEFAULT_LOOKUP_FIELD,
                 :desc => 'Specify the field name that IP address is stored (default: %s).' % DEFAULT_LOOKUP_FIELD

    config_param :output_field, :string, :default => DEFAULT_OUTPU_FIELD,
                 :desc => 'Specify the field name that store the result (default: %s).' % DEFAULT_OUTPU_FIELD

    config_param :field_delimiter, :string, :default => DEFAULT_FIELD_DELIMITER,
                 :desc => 'Specify the field delimiter (default %s).' % DEFAULT_FIELD_DELIMITER

    config_param :flatten, :bool, :default => DEFAULT_FLATTEN,
                 :desc => 'If true, to flatten the result using field_delimiter (default: %s).' % DEFAULT_FLATTEN

    config_param :locale, :string, :default => DEFAULT_LOCALE,
                 :desc => 'Get the data for the specified locale (default: %s).' % DEFAULT_LOCALE

    config_param :continent, :bool, :default => DEFAULT_CONTINENT,
                 :desc => 'If true, to get continent information (default: %s).' % DEFAULT_CONTINENT

    config_param :country, :bool, :default => DEFAULT_COUNTRY,
                 :desc => 'If true, to get country information (default: %s).' % DEFAULT_COUNTRY

    config_param :city, :bool, :default => DEFAULT_CITY,
                 :desc => 'If true, to get city information (default: %s).' % DEFAULT_CITY

    config_param :location, :bool, :default => DEFAULT_LOCATION,
                 :desc => 'If true, to get location information (default: %s).' % DEFAULT_LOCATION

    config_param :postal, :bool, :default => DEFAULT_POSTAL,
                 :desc => 'If true, to get postal information (default: %s).' % DEFAULT_POSTAL

    config_param :registered_country, :bool, :default => DEFAULT_REGISTERED_COUNTRY,
                 :desc => 'If true, to get registered country information (default: %s).' % DEFAULT_REGISTERED_COUNTRY

    config_param :represented_country, :bool, :default => DEFAULT_REPRESENTED_COUNTRY,
                 :desc => 'If true, to get represented country information (default: %s).' % DEFAULT_REPRESENTED_COUNTRY

    config_param :subdivisions, :bool, :default => DEFAULT_SUBDIVISIONS,
                 :desc => 'If true, to get subdivisions information (default: %s).' % DEFAULT_SUBDIVISIONS

    config_param :traits, :bool, :default => DEFAULT_TRAITS,
                 :desc => 'If true, to get traits information (default: %s).' % DEFAULT_TRAITS

    config_param :connection_type, :bool, :default => DEFAULT_CONNECTION_TYPE,
                 :desc => 'If true, to get connection type information (default: %s).' % DEFAULT_CONNECTION_TYPE

    config_param :autonomous_system, :bool, :default => DEFAULT_AUTONOMOUS_SYSTEM,
                 :desc => 'Autonomous System (default: %s).' % DEFAULT_AUTONOMOUS_SYSTEM





    def initialize
      super
    end

    def configure(conf)
      super

      if enable_auto_download then
        download_database @download_city_url, @md5_city_url, @database_city_path, @md5_city_path
        download_database @download_asn_url, @md5_asn_url, @database_asn_path, @md5_asn_path
      end

      @database_city = MaxMindDB.new(@database_city_path)
      @database_asn = MaxMindDB.new(@database_asn_path)
    end

    def filter(tag, time, record)
      ip = record[@lookup_field]

      unless ip.nil? then

        geoip_city = {}
        geoip_asn = {}
        begin
          geoip_city = @database_city.lookup(ip)
          geoip_asn = @database_asn.lookup(ip)
        rescue IPAddr::InvalidAddressError => e
          # Do nothing if if InvalidAddressError
          return record
        end

        if geoip_city.found? then

          unless @flatten then
            record.merge!({@output_field => {}})
          end

          if @continent then
            continent_hash = {}

            unless geoip_city.continent.code.nil? then
              continent_hash['continent_code'] = geoip_city.continent.code
            end
            unless geoip_city.continent.geoname_id.nil? then
              continent_hash['continent_geoname_id'] = geoip_city.continent.geoname_id
            end
            unless geoip_city.continent.iso_code.nil? then
              continent_hash['continent_iso_code'] = geoip_city.continent.iso_code
            end
            unless geoip_city.continent.name(@locale).nil? then
              continent_hash['continent_name'] = geoip_city.continent.name(@locale)
            end

            unless continent_hash.empty? then
              if @flatten then
                record.merge!(to_flatten(continent_hash, [@output_field], @field_delimiter))
              else
                record[@output_field].merge!(continent_hash)
              end
            end
          end

          if @country then
            country_hash = {}

            unless geoip_city.country.code.nil? then
              country_hash['country_code'] = geoip_city.country.code
            end
            unless geoip_city.country.geoname_id.nil? then
              country_hash['country_geoname_id'] = geoip_city.country.geoname_id
            end
            unless geoip_city.country.iso_code.nil? then
              country_hash['country'] = geoip_city.country.iso_code
            end
            unless geoip_city.country.name(@locale).nil? then
              country_hash['country_name'] = geoip_city.country.name(@locale)
            end

            unless country_hash.empty? then
              if @flatten then
                record.merge!(to_flatten(country_hash, [@output_field], @field_delimiter))
              else
                record[@output_field].merge!(country_hash)
              end
            end
          end

          if @city then
            city_hash = {}

            unless geoip_city.city.code.nil? then
              city_hash['city_code'] = geoip_city.city.code
            end
            unless geoip_city.city.geoname_id.nil? then
              city_hash['city_geoname_id'] = geoip_city.city.geoname_id
            end
            unless geoip_city.city.iso_code.nil? then
              city_hash['city_iso_code'] = geoip_city.city.iso_code
            end
            unless geoip_city.city.name(@locale).nil? then
              city_hash['city'] = geoip_city.city.name(@locale)
            end

            unless city_hash.empty? then
              if @flatten then
                record.merge!(to_flatten(city_hash, [@output_field], @field_delimiter))
              else
                record[@output_field].merge!(city_hash)
              end
            end
          end

          if @location then
            location_hash = {}

            unless geoip_city.location.latitude.nil? or geoip_city.location.longitude.nil? then
               location_hash['location'] = { "lat" => geoip_city.location.latitude, "lon" => geoip_city.location.longitude}
            end
            unless geoip_city.location.latitude.nil? then
              location_hash['latitude'] = geoip_city.location.latitude
            end
            unless geoip_city.location.longitude.nil? then
              location_hash['longitude'] = geoip_city.location.longitude
            end
            unless geoip_city.location.metro_code.nil? then
              location_hash['metro_code'] = geoip_city.location.metro_code
            end
            unless geoip_city.location.time_zone.nil? then
              location_hash['time_zone'] = geoip_city.location.time_zone
            end

            unless location_hash.empty? then
              if @flatten then
                record.merge!(to_flatten(location_hash, [@output_field], @field_delimiter))
              else
                record[@output_field].merge!(location_hash)
              end
            end
          end

          if @postal then
            postal_hash = {}

            unless geoip_city.postal.code.nil? then
              postal_hash['postal_code'] = geoip_city.postal.code
            end

            unless postal_hash.empty? then
              if @flatten then
                record.merge!(to_flatten(postal_hash, [@output_field], @field_delimiter))
              else
                record[@output_field].merge!(postal_hash)
              end
            end
          end

          if @registered_country then
            registered_country_hash = {}

            unless geoip_city.registered_country.code.nil? then
              registered_country_hash['code'] = geoip_city.registered_country.code
            end
            unless geoip_city.registered_country.geoname_id.nil? then
              registered_country_hash['geoname_id'] = geoip_city.registered_country.geoname_id
            end
            unless geoip_city.registered_country.iso_code.nil? then
              registered_country_hash['iso_code'] = geoip_city.registered_country.iso_code
            end
            unless geoip_city.registered_country.name(@locale).nil? then
              registered_country_hash['name'] = geoip_city.registered_country.name(@locale)
            end

            unless registered_country_hash.empty? then
              if @flatten then
                record.merge!(to_flatten(registered_country_hash, [@output_field, 'registered_country'], @field_delimiter))
              else
                record[@output_field].merge!({'registered_country' => registered_country_hash})
              end
            end
          end

          if @represented_country then
            represented_country_hash = {}

            unless geoip_city.represented_country.code.nil? then
              represented_country_hash['code'] = geoip_city.represented_country.code
            end
            unless geoip_city.represented_country.geoname_id.nil? then
              represented_country_hash['geoname_id'] = geoip_city.represented_country.geoname_id
            end
            unless geoip_city.represented_country.iso_code.nil? then
              represented_country_hash['iso_code'] = geoip_city.represented_country.iso_code
            end
            unless geoip_city.represented_country.name(@locale).nil? then
              represented_country_hash['name'] = geoip_city.represented_country.name(@locale)
            end

            unless represented_country_hash.empty? then
              if @flatten then
                record.merge!(to_flatten(represented_country_hash, [@output_field, 'represented_country'], @field_delimiter))
              else
                record[@output_field].merge!({'represented_country' => represented_country_hash})
              end
            end
          end

          if @subdivisions then
            subdivision_arry = []

            i = 0
            geoip_city.subdivisions.each do |subdivision|
              subdivision_hash = {}

              unless subdivision.code.nil? then
                subdivision_hash['code_%d' % [i]] = subdivision.code
              end
              unless subdivision.geoname_id.nil? then
                subdivision_hash['geoname_id_%d' % [i]] = subdivision.geoname_id
              end
              unless subdivision.iso_code.nil? then
                subdivision_hash['iso_code_%d' % [i]] = subdivision.iso_code
              end
              unless subdivision.name(@locale).nil? then
                subdivision_hash['name_%d' % [i]] = subdivision.name(@locale)
              end

              unless subdivision_hash.empty? then
                subdivision_arry.push(subdivision_hash)
              end

              i = i + 1
            end

            unless subdivision_arry.empty? then
              if @flatten then
                subdivision_arry.each do |subdivision|
                  record.merge!(to_flatten(subdivision, [@output_field, 'subdivisions'], @field_delimiter))
                end
              else
                record[@output_field].merge!({'subdivisions' => subdivision_arry})
              end
            end
          end

          if @traits then
            traits_hash = {}

            unless geoip_city.traits.is_anonymous_proxy.nil? then
              traits_hash['is_anonymous_proxy'] = geoip_city.traits.is_anonymous_proxy
            end
            unless geoip_city.traits.is_satellite_provider.nil? then
              traits_hash['is_satellite_provider'] = geoip_city.traits.is_satellite_provider
            end

            unless traits_hash.empty? then
              if @flatten then
                record.merge!(to_flatten(traits_hash, [@output_field, 'traits'], @field_delimiter))
              else
                record[@output_field].merge!({'traits' => traits_hash})
              end
            end
          end

          if @connection_type then
            unless geoip_city.connection_type.nil? then
              if @flatten then
                record.merge!(to_flatten(geoip_city.connection_type, [@output_field, 'connection_type'], @field_delimiter))
              else
                record[@output_field].merge!({'connection_type' => geoip_city.connection_type})
              end
            end
          end

          if geoip_asn.found? then
            if @autonomous_system then
              autonomous_system_hash = {}

              autonomous_system_hash['number'] = geoip_asn['autonomous_system_number']
              autonomous_system_hash['organization'] = geoip_asn['autonomous_system_organization']

              unless autonomous_system_hash.empty? then
                if @flatten then
                  record.merge!(to_flatten(autonomous_system_hash, [@output_field, 'as'], @field_delimiter))
                else
                  record[@output_field].merge!({'as' => autonomous_system_hash})
                end
              end
            end
          end

          log.debug "Record: %s" % record.inspect
        else
          log.debug "It was not possible to look up the #{ip}."
        end
      end

      return record
    end

    def to_flatten(hash, stack=[], delimiter='/')
      output = {}

      hash.keys.each do |key|
        stack.push key

        if hash[key].instance_of?(Hash) then
          output.merge!(to_flatten(hash[key], stack, delimiter))
        else
          output[stack.join(delimiter)] = hash[key]
        end

        stack.pop
      end

      return output
    end

    def download_database(download_url, md5_url, database_path, md5_path)
      # database directory
      database_dir = File.dirname database_path
      md5_dir = File.dirname md5_path

      # create database directory if directory does not exist.
      FileUtils.mkdir_p(database_dir) unless File.exist?(database_dir)
      FileUtils.mkdir_p(md5_dir) unless File.exist?(md5_dir)

      # create empty md5 file if file does not exist.
      File.open(md5_path, 'wb').close() unless File.exist?(md5_path)

      # read saved md5
      current_md5 = nil
      begin
        open(md5_path, 'rb') do |data|
          current_md5 = data.read
        end
        log.info "Current MD5: %s" % current_md5
      rescue => e
        log.warn e.message
      end

      # fetch md5
      fetched_md5 = nil
      begin
        open(md5_url, 'rb') do |data|
          fetched_md5 = data.read
        end
        log.info "Fetched MD5: %s" % fetched_md5
      rescue => e
        log.warn e.message
      end

      # check md5
      unless current_md5 == fetched_md5 then
        # download new database
        download_path = database_dir + '/' + File.basename(download_url)
        begin
          log.info "Download: %s" % download_url
          open(download_path, 'wb') do |output|
            open(download_url, 'rb') do |data|
              output.write(data.read)
            end
          end
          log.info "Download done: %s" % download_path
        rescue => e
          log.warn e.message
        end

        # unzip new database temporaly
        tmp_database_path = database_dir + '/tmp_' + File.basename(database_path)
        log.info "temp_database_path: %s" %  tmp_database_path
        log.info "PWD %s" % File.expand_path(tmp_database_path)
        begin
          log.info "Unzip: %s" % download_path
            Zlib::GzipReader.open(download_path) do |gz|
            Archive::Tar::Minitar.unpack(gz, './tmp')
          end
          src_path = Dir.glob('./tmp/' + File.basename(download_path, ".tar.gz") + '_*/' + File.basename(download_path, ".tar.gz")  + '.mmdb')
          FileUtils.mv(src_path, database_dir)
          FileUtils.rm_rf('./tmp')
          log.info "Unzip done: %s" % tmp_database_path
        rescue => e
          puts e.message
        end

        # check mkd5
        temp_md5 = Digest::MD5.hexdigest(File.open(download_path, 'rb').read)
        log.info "New MD5: %s" % temp_md5
        if fetched_md5 == temp_md5 then
          # record new md5
          log.info "Save: %s" % md5_path
          File.write(md5_path, fetched_md5)
          log.info "Save done: %s" % md5_path
        else
          log.info "MD5 missmatch: Fetched MD5 (%s) != New MD5 (%s) ; " % [fetched_md5, temp_md5]
        end
      end
    end
  end
end
