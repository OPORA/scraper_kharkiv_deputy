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
    url = "http://www.city.kharkov.ua/ru/gorodskaya-vlast/gorodskoj-sovet/deputatyi.html#all"
    session = Capybara::Session.new(:poltergeist)
    session.visit(url)
    session.all('#deputy_container .tbody .row').each do |mp|
      full_name = mp.find('.lf_name .last_name').text + " " +  mp.find('.lf_name .first_name').text
      photo_url = "http://www.city.kharkov.ua" + get_page(mp.all('.lf_name a')[0][:href]).css('.box_photo img')[0][:src]
      faction = mp.find('.party a').text
      i = i + 1
      date_start = case
                     when full_name == "Медведев Юрий Игоревич"
                       "2016-05-18"
                     when full_name == "Кривуля Виталий Евгеньевич"
                       "2016-09-07"
                     when full_name == "Китанин Виктор Александрович"
                       "2016-10-18"
                     when full_name == "Гунбина Елена Владимировна"
                       "2017-01-16"
                     else
                       "2015-11-18"
                   end
      date_end = case
                   when full_name == "Чепель Андрей Алексеевич"
                     "2016-12-21"
                   else
                     "9999-12-31"
                 end

      scrape_mp(full_name, nil, faction, photo_url, i, date_start, date_end)
    end
    resigned_mp()
    create_mer()
  end
  def create_mer
    #TODO create mer Kernes
    names = %w{Кернес Геннадий Адольфович}
    People.first_or_create(
        first_name: names[1],
        middle_name: names[2],
        last_name: names[0],
        full_name: names.join(' '),
        deputy_id: 1111,
        okrug: nil,
        photo_url: "http://www.city.kharkov.ua/assets/images/kernes.jpg",
        faction: nil,
        start_date: "2015-11-18" ,
        end_date: "9999-12-31",
        created_at: "9999-12-31"
    )
  end
  def get_page(url)
    Nokogiri::HTML(open(url, "User-Agent" => "HTTP_USER_AGENT:Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US) AppleWebKit/534.13 (KHTML, like Gecko) Chrome/9.0.597.47"), nil, 'utf-8')
  end
  def resigned_mp
    mp = []
    mp << {fio: "Лесик Андрей Анатольевич", okrug: nil, party: "За Харьков, за Возрождение", image: "http://lesik.kharkov.ua/images/lesik_andrey.png", rada_id: 2000 , date_start: "2015-11-18", date_end: "2016-05-17"}
    mp << {fio: "Коринько Иван Васильевич", okrug: nil, party: "За Харьков, за Возрождение", image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJpGOXa3AVhLBiRbf1q5dijotS5wQOQ6V1BqYjgRIPaEvorhQO06KFpJhl", rada_id: 2001 , date_start: "2015-11-18", date_end: "2016-06-30"}
    mp << {fio: "Дегтярьов Николай Іванович", okrug: nil, party: "За Харьков, за Возрождение", image: "http://img3.sq.com.ua/image/88/133/img-articles-vip-dosie-degtiarev_n_i.jpg", rada_id: 2002 , date_start: "2015-11-18", date_end: "2016-09-14"}
    mp.each do |m|
      scrape_mp(m[:fio], m[:okrug], m[:party], m[:image], m[:rada_id], m[:date_start], m[:date_end])
    end
  end
  def scrape_mp(fio, okrug, party, image, rada_id, date_start, date_end)
    party = case
              when party[/СОЛИДАРНОСТЬ/]
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
    people.update(end_date:  date_end, start_date: date_start, updated_at: Time.now)
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
          start_date: date_start,
          created_at: Time.now,
          updated_at: Time.now
      )
    end
  end
end
unless ENV['RACK_ENV']
  ScrapeMp.new
end


