require 'nokogiri'
require 'open-uri'
require 'csv'

class InciBeauty
    
    def scrap_detail_page(url)
        begin
            page = Nokogiri::HTML(open(url))
            rating = page.css(".content-fleur").css("span").first.content
            rating = rating.scan(/"([^"]*)"/).join()
            # puts rating

            ingredient_name = page.css(".list-unstyled").css("li:contains('Nom INCI ')").first.content
            ingredient_name = ingredient_name.partition(': ').last
            # puts ingredient_name
            [ingredient_name, rating]
        rescue StandardError => e
            puts "Error: #{e.inspect}"
        end
    end

    def scrap_list(url)
        page = Nokogiri::HTML(open(url))
        table = page.css("table")
        elements = table.css("tr")
        result = []
        elements.each do |element|
            link =  element.css("td")[1].css("a").first["href"]
            result << link
        end
        result
    end

    def list_urls
        list = ["https://incibeauty.com/ingredients/1"]
        for letter in "A".."Z" do
            url = "https://incibeauty.com/ingredients/#{letter}"
            list << url
        end
        list
    end

    def store_to_csv(array)
        CSV.open("incibeauty.csv", "a+") do |csv|
            csv << array
        end
    end

    def start
        list_urls = list_urls()
        detail_pages = []
        list_urls.each do |list_url|
            detail_pages << scrap_list(list_url)
            sleep(2)
        end
        detail_pages.flatten!
        detail_pages.each do |url_page|
            page_result = scrap_detail_page(url_page)
            store_to_csv(page_result) if !page_result.nil?
            sleep(2)
        end
    end
end

incy = InciBeauty.new

incy.start
# puts incy.scrap_list(ARGV[0])
# puts incy.scrap_detail_page(ARGV[0])
# incy.store_to_csv(incy.scrap_detail_page(ARGV[0]))