require 'open-uri'
require 'pry'
require 'uri'

class Scraper
  BASE_PATH = "./fixtures/student-site/"

  def self.scrape_index_page(index_url)
    html = open(index_url)
    index_page = Nokogiri::HTML(html)

    students = []

    index_page.css(".roster-cards-container div.student-card").each do |student|
      students << {
        :name => student.css("a div.card-text-container h4.student-name").text,
        :location => student.css("a div.card-text-container p.student-location").text,
        :profile_url => BASE_PATH + student.css("a").attribute("href").value
      }
    end
    students
  end

  def self.scrape_profile_page(profile_url)
    html = open(profile_url)
    profile_page = Nokogiri::HTML(html)

    student = {}

    vitals_links_css = profile_page.css("div.vitals-container .social-icon-container a")
    vitals_links_css.each_with_index do |social, index|
      domain = parse_social_link(vitals_links_css[index].attribute("href").value)
      student[domain] = vitals_links_css[index].attribute("href").value
    end

    student[:profile_quote] = profile_page.css("div.vitals-container .vitals-text-container .profile-quote").text
    student[:bio] = profile_page.css("div.details-container .bio-content .description-holder p").text
    student
  end

  def self.parse_social_link(social_url)
    uri = URI.parse(social_url)
    uri = URI.parse("https://#{social_url}") if uri.scheme.nil?
    host = uri.host.to_s.downcase # Note: had to add .to_s in order for the run the command_line_interface.rb
                                  # It was giving an error "undefined method `downcase' for nil:NilClass (NoMethodError)"
                                  # which meant that it was trying to perform a string method on an array.
    domain = host.start_with?('www.') ? host[4..-1].split('.') : host.split('.')
    if domain[0] != "twitter" && domain[0] != "linkedin" && domain[0] != "github"
      "blog".to_sym
    else
      domain[0].to_sym
    end
  end

end
