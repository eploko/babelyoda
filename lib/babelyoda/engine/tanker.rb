require 'builder'
require 'net/http'
require 'nokogiri'
require 'stringio'

require 'babelyoda/specification_loader'

require_relative 'base'

module Babelyoda
	module Engine
		class Tanker < Base
			include Babelyoda::SpecificationLoader
			
			class FileNameInvalidError < RuntimeError ; end

	    attr_accessor :endpoint
	    attr_accessor :token
	    attr_accessor :project_id

      def replace(keyset_name, strings, language = 'en')
        post('/keysets/replace/', { 
          :file => StringIO.new(records_to_xml(keyset_name, strings.to_a, language)),
          'project-id' => project_id,
          'keyset-id' => keyset_name,
          :format => 'xml',
          :language => language
        })
      end
      
      def list
        get('/keysets/', { 'project-id' => project_id }).css('keyset').map { |keyset| keyset['id'] }
      end
      
      def create(keyset_name)
        post('/keysets/create/', { 'project-id' => project_id, 'keyset-id' => keyset_name })
      end
      
    private
    
      MULTIPART_BOUNDARY = '114YANDEXTANKERCLIENTBNDR';

      def multipart_content_type
        "multipart/form-data; boundary=#{MULTIPART_BOUNDARY}"
      end

      def method(name)
        "#{endpoint}#{name}"
      end

      def records_to_xml(keyset_name, records, language = 'en')
        xml = Builder::XmlMarkup.new
        xml.instruct!(:xml, :encoding => "UTF-8")
        xml.tanker do
          xml.project(:id => project_id) do
            xml.keyset(:id => keyset_name) do
              records.each do |rec|
                xml.key(:id => rec[:key], :is_plural => 'False') do
                  xml.context(rec[:comment])
                  xml.value(rec[:value], :language => language, :status => 'requires_translation')
                end
              end
            end
          end
        end
      end

      def multipart_data(payload = {}, boundary = MULTIPART_BOUNDARY)
        payload.keys.map { |k|
          "--#{boundary}\r\n" + multipart_field(k, payload[k])
        }.join('') + "--#{boundary}--\r\n"
      end

      def multipart_field(k, v)
        if v.respond_to?(:read)
          "Content-Disposition: form-data; name=\"#{k}\"; filename=\"#{k}.xml\"\r\n" +
          "Content-Type: application/octet-stream\r\n" +
          "Content-Transfer-Encoding: binary\r\n\r\n" +
          "#{v.read}\r\n"
        else
          "Content-Disposition: form-data; name=\"#{k}\"\r\n\r\n" +
          "#{v}\r\n"
        end
      end

      def post(method_name, payload)
        uri = URI(method(method_name))
        req = Net::HTTP::Post.new(uri.path)
        req['AUTHORIZATION'] = token
        req.content_type = multipart_content_type
        req.body = multipart_data(payload)

        # puts "POST URI: #{uri}"
        # puts "POST BODY: #{req.body}"

        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req)
        end

        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          Nokogiri::XML.parse(res.body)
        else
          doc = Nokogiri::XML.parse(res.body)
          error = doc.css('result error')[0].content
          raise Error.new(error)
        end
      end

      def get(method_name, payload = nil)
        uri = URI(method(method_name))
        uri.query = URI.encode_www_form(payload) if payload
        req = Net::HTTP::Get.new(uri.request_uri)
        req['AUTHORIZATION'] = token

        # puts "GET URI: #{uri}"

        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req)
        end

        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          Nokogiri::XML.parse(res.body)
        else
          doc = Nokogiri::XML.parse(res.body)
          error = doc.css('result error')[0].content
          raise Error.new(error)
        end
      end
		end
	end
end
