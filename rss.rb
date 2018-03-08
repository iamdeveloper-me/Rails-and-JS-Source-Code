class DataAdapters::Rss < DataAdapters::Base

  statistic 'feeds[@rss_feed_url].entries', group: :static, ranges: [ 1 ]

  scope 'url',
    control: :text,
    placeholder: 'Type a valid URL',
    validate: :validate_url

  view :rssfeed,
    statistics: [ 'feeds[@rss_feed_url].entries' ],
    scope: {
      rss_feed_url: {
        type: 'url',
        label: 'RSS feed',
        required: true
      }
    },
    name: 'RSS feed',
    description: 'Get the latest content of an RSS feed.',
    chart_pane_config: {
      span_x: 3,
      span_y: 2,
      layout: 'table',
      empty: 'No entries were found.',
      source: { id: 'feeds[@rss_feed_url].entries' },
      table: {
        columns: [
          {
            primary: { type: 'value', source: { id: 'title' }, url: { id: 'link' } },
            secondary: { type: 'value', source: { id: 'description' } }
          }
        ]
      }
    }

  around_processor :catch_errors

  # Processor for static statistics
  processor :get_feed,
            statistics: [ 'feeds[@rss_feed_url].entries' ]


  # An around filter to catch general API errors and throw the Ruminant equivalent
  def catch_errors(data, view_config, options)
    begin
      yield
    rescue Feedjira::NoParserAvailable
      raise Ruminant::DataInvalidException.new
    end
  end

  def validate_url(value, context = {})
    if value =~ /^https?:\/\/.+$/i
      {
        valid: true
      }
    else
      {
        valid: false,
        message: 'URL must begin with http:// or https://.'
      }
    end
  end

  def get_feed(data, view_config, options)
    data['feeds'] ||= collection([])
    url = view_config['scope']['rss_feed_url']
    feed = update_collection_member(data['feeds'], url, { 'id' => identifier(url) })
    return if feed.has_key?('entries') &&
              !options[:refresh]
    feed_entries = get_cached_feed(url)["entries"]
    feed['entries'] = feed_entries.each_with_index.map do |e,i|
      {
        'id' => identifier(i),
        'title' => string( e['title'] ),
        'link' => url(e['link']),
        'description' => string(e['description'])
      }
    end
    update_collection_member(data['feeds'], url, feed )
  end


  # **********************************************
  # DATA FETCHERS
  # ----------------------------------------------

  def get_cached_feed(url)
    return scoped_request('rss-feed', { url: url }) do |rc|
      rss = open_rss_feed(url)
      rc.done( rss, 1)
    end
  end

  def open_rss_feed(url)
    rss = Feedjira::Feed.fetch_and_parse url
    if rss.is_a?(Fixnum)
      preamble = "We attempted to retrieve your RSS feed, but"
      message = case rss
      when 0
        "#{preamble} it looks like the server could not be found. Please check the address and try again"
      when 401
        "#{preamble} it requires a username and password (HTTP error 401)"
      when 404
        "#{preamble} the server could not find it (HTTP error 404). Please check the address and try again"
      when 500
        "#{preamble} the server returned a generic error (HTTP error 500). If this error does not resolve itself in time, please contact the feed's owner"
      when 503
        "#{preamble} the server was either too busy or taking a break (HTTP error 503). If this error does not resolve itself in time, please contact the feed's owner"
      else
        "#{preamble} encountered an unspecified error. Please check the address and try again, or contact support for additional assistance"
      end
      raise Ruminant::ConfigurationInvalidException.new({
        message: "#{message}; url: #{url}",
        public_message: message
      })
    end
    entr = rss.entries.map { |e| { title: e.title, link: e.url, description: ActionView::Base.full_sanitizer.sanitize(e.summary) } }
    return { title: rss.title, entries: entr }
  end

end
