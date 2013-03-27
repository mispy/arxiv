require 'open-uri'
require 'nokogiri'
require 'happymapper'
require 'cgi'

require 'arxiv/version'
require 'arxiv/string_scrubber'

require 'arxiv/models/author'
require 'arxiv/models/link'
require 'arxiv/models/category'
require 'arxiv/models/manuscript'

module Arxiv

  module Error
    class ManuscriptNotFound < StandardError ; end
    class MalformedId < StandardError ; end
  end

  # In 2007, the ArXiv API changed document ID formats:
  #
  #    http://arxiv.org/abs/math/0510097v1  (legacy)
  #    http://arxiv.org/abs/1202.0819v1     (current)
  #
  # These constants help us deal with both use cases.
  #
  LEGACY_URL_FORMAT = /[^\/]+\/\d+(?:v\d+)?$/
  CURRENT_URL_FORMAT = /\d{4}\.\d{4}(?:v\d+)?$/

  LEGACY_ID_FORMAT = /^#{LEGACY_URL_FORMAT}/
  ID_FORMAT = /^#{CURRENT_URL_FORMAT}/

  def self.get(identifier)
    id = parse_arxiv_identifier(identifier)

    unless id =~ ID_FORMAT || id =~ LEGACY_ID_FORMAT
      raise Arxiv::Error::MalformedId, "Manuscript ID format is invalid"
    end

    manuscripts = query(:id_list => id)

    raise Arxiv::Error::ManuscriptNotFound, "Manuscript #{id} doesn't exist on arXiv" if manuscripts.length == 0
    manuscripts[0]
  end

  def self.query(params)
    paramstr = params.collect { |k,v| "#{k}=#{::CGI::escape(v.to_s)}" }.join('&')
    url = ::URI.parse("http://export.arxiv.org/api/query?#{paramstr}")
    response = ::Nokogiri::XML(open(url)).remove_namespaces!
    Arxiv::Manuscript.parse(response.to_s).reject { |m| m.title.nil? }
  end

  private

  def self.parse_arxiv_identifier(identifier)
    if valid_id?(identifier)
      identifier
    elsif valid_url?(identifier)
      format = legacy_url?(identifier) ? LEGACY_URL_FORMAT : CURRENT_URL_FORMAT
      identifier.match(/(#{format})/)[1]
    else
      identifier # probably an error
    end
  end

  def self.valid_id?(identifier)
    identifier =~ ID_FORMAT || identifier =~ LEGACY_ID_FORMAT
  end

  def self.valid_url?(identifier)
    identifier =~ LEGACY_URL_FORMAT || identifier =~ CURRENT_URL_FORMAT
  end

  def self.legacy_url?(identifier)
    identifier =~ LEGACY_URL_FORMAT
  end
end
