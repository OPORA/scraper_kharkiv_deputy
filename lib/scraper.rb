require 'open-uri'
require 'nokogiri'
require_relative './people'
require 'capybara'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
options = {js_errors: false}
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, options)
end
class ScrapeMp
  def parser
    i = 3000
    url = "http://www.city.kharkov.ua/uk/gorodskaya-vlast/gorodskoj-sovet/deputatyi.html#all"
    session = Capybara::Session.new(:poltergeist)
    session.visit(url)
    session.all('#deputy_container .tbody .row').each do |mp|
      full_name = mp.find('.lf_name .last_name').text + " " +  mp.find('.lf_name .first_name').text
      photo_url = "http://www.city.kharkov.ua" + get_page(mp.all('.lf_name a')[0][:href]).css('.box_photo img')[0][:src]
      faction = mp.find('.party a').text
      i = i + 1
      scrape_mp(full_name, nil, faction, photo_url, i)
    end
    #resigned_mp()
    create_mer()
  end
  def create_mer
    #TODO create mer Kernes
    names = %w{Кернес Геннадій Адольфович}
    People.first_or_create(
        first_name: names[1],
        middle_name: names[2],
        last_name: names[0],
        full_name: names.join(' '),
        deputy_id: 1111,
        okrug: nil,
        photo_url: "http://www.city.kharkov.ua/assets/images/kernes.jpg",
        faction: nil,
        end_date: nil,
        created_at: "9999-12-31"
    )
  end
  def get_page(url)
    Nokogiri::HTML(open(url, "User-Agent" => "HTTP_USER_AGENT:Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.47"), nil, 'utf-8')
  end
  def resigned_mp
    uri = ""
    page_resigned = get_page(uri)
    scrape_mp( )
  end
  def scrape_mp(fio, okrug, party, image, rada_id ,date_end=nil)
    party = case
              when party[/СОЛІДАРНІСТЬ/]
                "Блок Петра Порошенка"
              when party[/САМОПОМІЧ/]
                "Самопоміч"
              when party[/Наш край/]
                "Наш край"
              else
                party
            end

    name = fio.gsub(/\s{2,}/,' ')
    name_array = name.split(' ')
    people = People.first(
        first_name: name_array[1],
        middle_name: name_array[2],
        last_name: name_array[0],
        full_name: name_array.join(' '),
        okrug: okrug,
        photo_url: image,
        faction: party,
    )
    unless people.nil?
    people.update(end_date:  date_end,  updated_at: Time.now)
    else
      People.create(
          first_name: name_array[1],
          middle_name: name_array[2],
          last_name: name_array[0],
          full_name: name_array.join(' '),
          deputy_id: rada_id,
          okrug: okrug,
          photo_url: image,
          faction: party,
          end_date:  date_end,
          created_at: Time.now,
          updated_at: Time.now
      )
    end
  end
end
unless ENV['RACK_ENV']
  ScrapeMp.new
end


