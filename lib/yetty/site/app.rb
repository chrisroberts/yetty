require 'cowsay'
require 'base64'
require 'sinatra/base'

module Yetty
  class Site
    # Web UI
    class App < Sinatra::Base

      def bucket
        storage = Miasma.api(
          :type => :storage,
          :provider => :aws,
          :credentials => {
            :aws_access_key_id => ENV['MIASMA_AWS_ACCESS_KEY_ID'],
            :aws_secret_access_key => ENV['MIASMA_AWS_SECRET_ACCESS_KEY'],
            :aws_region => ENV['MIASMA_AWS_REGION'],
            :aws_bucket_region => 'us-west-2'
          }
        )
        bucket = storage.buckets.get('cr-test-00')
      end

      set :public_folder, File.join(File.dirname(__FILE__), 'static')

      get '/' do
        haml :index
      end

      get '/recording/:info' do
        rec_path = Base64.urlsafe_decode64(params[:info])
        user, state, name = rec_path.split('/')
        rec_url = bucket.files.get(rec_path).url
        haml(
          :recording,
          :locals => {
            :user => user,
            :state => state,
            :name => name,
            :url => rec_url
          }
        )
      end

      get '/users/:username' do
      end

      get '/about' do
        haml :about
      end

    end
  end
end
