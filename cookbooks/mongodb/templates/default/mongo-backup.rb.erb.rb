#!/usr/bin/env ruby

require 'rubygems'
require 'aws/s3'
require 'date'
require 'digest'
require 'net/http'
require 'fileutils'

module AWS::S3
  class S3Object
    def <=>(other)
      DateTime.parse(self.about['last-modified']) <=> DateTime.parse(other.about['last-modified'])
    end
  end
end

AWS::S3::Base.establish_connection!(
  :access_key_id     => '<%= @id_key %>',
  :secret_access_key => '<%= @secret_key %>'
)
@dbuser = '<%= @username %>'
@dbpass = '<%= @password %>'
@databases = ['<%= @database %>']
@environment = '<%= @env %>'
@app_name = '<%= @app_name %>'
@collections = [ 'system.indexes', 'system.users', 'keywords', 'training_programs', 'segments', 'transcripts', 'media_file_data' ]
@keep = 10 * @collections.length
@bucket = "ey-backup-#{Digest::SHA1.hexdigest('<%= @id_key %>')[0..11]}-mongo"
@tmpname = "#{Time.now.strftime("%Y-%m-%dT%H:%M:%S").gsub(/:/, '-')}"
FileUtils.mkdir_p '/mnt/tmp'
begin
  AWS::S3::Bucket.create @bucket
rescue AWS::S3::BucketAlreadyExists
end

@databases.each do |database|
  @collections.each do |collection|
    token = "#{database}-#{collection}"
    mongocmd = "mongodump -h 127.0.0.1 -d #{database} -c #{collection} -u #{@dbuser} -p #{@dbpass} -o /mnt/tmp/#{token}.#{@tmpname} && tar cjf \"/mnt/tmp/#{token}.#{@tmpname}.tar.bz\" \"/mnt/tmp/#{token}.#{@tmpname}\""
    if system(mongocmd)
      AWS::S3::S3Object.store(
        "/#{@environment}.#{@app_name}/#{@app_name}-#{collection}.#{@tmpname}.bson.tar.bz",
        open("/mnt/tmp/#{token}.#{@tmpname}.tar.bz"),
        @bucket,
        :access => :private
      )
      FileUtils.rm "/mnt/tmp/#{token}.#{@tmpname}.tar.bz"
      FileUtils.rm_r "/mnt/tmp/#{token}.#{@tmpname}"
      puts "successful backup: #{database}.#{@tmpname}"
    else
      raise "Unable to dump database#{database} wtf?"
    end
  end
end

backups = []
backups << AWS::S3::Bucket.objects(@bucket).sort
backups = backups.flatten.sort
backups[0...-@keep].each do |object|
  puts "deleting: #{object.key}"
  object.delete
end