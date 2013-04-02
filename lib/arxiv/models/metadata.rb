module Arxiv
  class Metadata
    include HappyMapper

    tag 'arXiv'
    element :id, String
    element :created, DateTime
    element :updated, DateTime
    element :title, StringScrubber, parser: :scrub
    element :abstract, StringScrubber, parser: :scrub
    element :comments, StringScrubber, parser: :scrub
    has_many :categories, Category
    has_many :authors, Author

    def primary_category
      categories[0]
    end

    def revision?
      created_at != updated_at
    end

    def legacy_article?
      id =~ Arxiv::LEGACY_URL_FORMAT
    end

    def version
      id.match(/v(\d+)$/)[1].to_i
    end
  end
end
