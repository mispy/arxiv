module Arxiv
  class Author
    include HappyMapper
    element :onename, StringScrubber, parser: :scrub, tag: 'name'
    has_many :affiliations, StringScrubber, parser: :scrub, tag: 'affiliation'
    
    # Metadata author
    element :forenames, StringScrubber, parser: :scrub, tag: 'forenames'
    element :keyname, StringScrubber, parser: :scrub, tag: 'keyname'

    def name
      if onename
        onename
      elsif forenames.nil?
        keyname
      else
        "#{forenames} #{keyname}"
      end
    end
  end
end
