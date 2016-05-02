#! /usr/local/bin/ruby

require 'rss'
require 'open-uri'
require 'yaml'

uri = 'http://b.hatena.ne.jp/hotentry/it.rss'

def check_url(url)
  config_file = 'ng_url_list.yaml'
  ng_list = YAML.load_file(config_file)
  ng_list.each do |ng|
    if url.match(ng)
      return nil
    end
  end
end

def get_rss(uri)
  opt = {}
  opt['User-Agent'] = 'Opera/9.80 (Windows NT 5.1)'

  open(uri, opt) do |rss|
    feed = RSS::Parser.parse(rss)
    myfeed = feed.items.map{ |item|
      if check_url( item.link )
        { 'title' => item.title,
          'date'  => item.dc_date.to_s,
          'url'   => item.link }
      end
    }
    {
      'title' => feed.channel.title,
      'feed'  => myfeed
    }
  end
end


rss = RSS::Maker.make("1.0") do |maker|
  maker.channel.author      = "kirine"
  maker.channel.updated     = Time.now.to_s
  maker.channel.about       = "myHatenaBookmark"
  maker.channel.description = "myHatenaBookmark"
  maker.channel.title       = "myHatenaBookmark"
  maker.channel.link        = "http://reader.example.com/get_rss.rb"

  body = get_rss(uri)
  body['feed'].each do |f|
    if f then
    maker.items.new_item do |item|
      item.link = f['url']
      item.title = f['title']
      item.dc_date = f['date']
    end
    end
  end
end

print "Content-Type: text/xml\n\n"
print rss
