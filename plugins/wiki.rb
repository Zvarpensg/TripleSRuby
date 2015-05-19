require 'open-uri'

class Wiki
  include Cinch::Plugin
  include Authentication
  include OpenURI

  match /wiki (.+)/, method: :wiki

  def wiki(m, args)

    def pageForTitle(encodedUrl)
      resp = JSON.parse open(encodedUrl).read
      page = resp["query"]["pages"].values[0]
      return page
    end

    api = "http://en.wikipedia.org/w/api.php?format=json&action=query&titles=%s&prop=extracts%%7Cinfo&exchars=300&explaintext&inprop=url&redirects"
    puts (api % URI::encode(args))
    page = pageForTitle (api % URI::encode(args))
    extract = page["extract"]
    if extract.nil?
      # Try again with the query lowercased
      page = pageForTitle (api % URI::encode(args.downcase))
      extract = page["extract"]

      if extract.nil?
        # definitely no page this time, not that we can tell anyway
        m.channel.send "No page found for #{args}."
        return
      end

    end
    if extract.length > 350 # just in case wikipedia goes crazy and joins skynet
      extract = extract[0,350]
    end
    m.channel.send extract
    m.channel.send page["fullurl"]
  end
end
