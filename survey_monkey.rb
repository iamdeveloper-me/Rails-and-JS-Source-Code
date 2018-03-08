class DataAdapters::SurveyMonkey < DataAdapters::Base
  MAX_RECENT_SURVEYS = 5
  PAGE_MULTIPLIER = 10000
  statistic 'recent_surveys', group: :static
  
  statistic 'surveys[@surveymonkey_survey_id].name', group: :static
  statistic 'surveys[@surveymonkey_survey_id].status', group: :static
  statistic 'surveys[@surveymonkey_survey_id].created_at', group: :static

  statistic 'surveys[@surveymonkey_survey_id].analysis_url', group: :static
  statistic 'surveys[@surveymonkey_survey_id].num_questions', group: :static
  statistic 'surveys[@surveymonkey_survey_id].num_pages', group: :static
  statistic 'surveys[@surveymonkey_survey_id].num_responses', group: :static
  statistic 'surveys[@surveymonkey_survey_id].num_complete', group: :static
  statistic 'surveys[@surveymonkey_survey_id].num_incomplete', group: :static

  statistic 'surveys[@surveymonkey_survey_id].pct_complete', group: :static
  statistic 'surveys[@surveymonkey_survey_id].pct_incomplete', group: :static

  statistic 'surveys[@surveymonkey_survey_id].response_total', group: :archived
  statistic 'surveys[@surveymonkey_survey_id].responses_by_question', group: :static, ranges: [ 1 ]
  statistic 'surveys[@surveymonkey_survey_id].responses_by_page', group: :static, ranges: [ 1 ]
  statistic 'surveys[@surveymonkey_survey_id].recent_responders', group: :static

  view :survey_details,
    statistics: [ 
      'surveys[@surveymonkey_survey_id].name',
      'surveys[@surveymonkey_survey_id].status',
      'surveys[@surveymonkey_survey_id].created_at',
      'surveys[@surveymonkey_survey_id].num_questions',
      'surveys[@surveymonkey_survey_id].num_pages',
      'surveys[@surveymonkey_survey_id].num_responses'
    ],
    configuration_fields: {
      surveymonkey_survey_id: true,
    },
    chart_pane_config: {
      layout: 'survey-overview',
      span_x: 2,
      span_y: 2,
      name:          { id: 'surveys[@surveymonkey_survey_id].name' },
      created_at:    { id: 'surveys[@surveymonkey_survey_id].created_at' },
      status:        { id: 'surveys[@surveymonkey_survey_id].status' },
      num_questions: { id: 'surveys[@surveymonkey_survey_id].num_questions', label: 'Questions' },
      num_pages:     { id: 'surveys[@surveymonkey_survey_id].num_pages', label: 'Pages' },
      num_responses: { id: 'surveys[@surveymonkey_survey_id].num_responses' }
    }

  view :responses_by_day,
    statistics: [ 'surveys[@surveymonkey_survey_id].response_total' ],
    configuration_fields: {
      surveymonkey_survey_id: true,
    },
    chart_pane_config: {
      span_x: 3,
      span_y: 2,
      layout: 'basic',
      statistic_list: {
        diffs: 'dw'
      },
      chart: {
        type: 'line'
      },
      statistics: [
        { id: 'surveys[@surveymonkey_survey_id].response_total' }
      ]
    }

  view :survey_completion,
    statistics: [ 
      'surveys[@surveymonkey_survey_id].analysis_url',
      'surveys[@surveymonkey_survey_id].created_at',
      'surveys[@surveymonkey_survey_id].name',
      'surveys[@surveymonkey_survey_id].num_complete',
      'surveys[@surveymonkey_survey_id].num_incomplete',
      'surveys[@surveymonkey_survey_id].pct_complete',
      'surveys[@surveymonkey_survey_id].pct_incomplete',
    ],
    configuration_fields: {
      surveymonkey_survey_id: true,
    },
    chart_pane_config: {
      layout: "survey-completion", 
      span_x: 3,
      span_y: 2,
      analysis_url:   { id: 'surveys[@surveymonkey_survey_id].analysis_url' },
      created_at:     { id: 'surveys[@surveymonkey_survey_id].created_at' },
      name:           { id: 'surveys[@surveymonkey_survey_id].name' },
      num_complete:   { id: 'surveys[@surveymonkey_survey_id].num_complete' },
      num_incomplete: { id: 'surveys[@surveymonkey_survey_id].num_incomplete' },
      num_responses:  { id: 'surveys[@surveymonkey_survey_id].num_responses' },
      pct_complete:   { id: 'surveys[@surveymonkey_survey_id].pct_complete' },
      pct_incomplete: { id: 'surveys[@surveymonkey_survey_id].pct_incomplete' }
    }

  view :responses_by_question,
    statistics: [ 'surveys[@surveymonkey_survey_id].responses_by_question' ],
    configuration_fields: {
      surveymonkey_survey_id: true
    },
    chart_pane_config: {
      span_x: 4,
      span_y: 2,
      layout: 'funnel',
      statistics: { id: 'surveys[@surveymonkey_survey_id].responses_by_question', diffs: 'dw' },
      funnel: {
        autoGroup: true,
        groupingLabelSingular: 'Question # %a',
        groupingLabelPlural: 'Questions # %a to %z'
      }
    }

  view :responses_by_question_bar,
    statistics: [ 'surveys[@surveymonkey_survey_id].responses_by_question' ],
    configuration_fields: {
      surveymonkey_survey_id: true
    },
    chart_pane_config: {
      span_x: 4,
      span_y: 2,
      layout: 'bar',
      statistics: { id: 'surveys[@surveymonkey_survey_id].responses_by_question', diffs: 'dw' },
      bar: {
        autoGroup: true,
        groupingLabelSingular: 'Question # %a',
        groupingLabelPlural: 'Questions # %a to %z'
      }
    }

  view :responses_by_page,
    statistics: [ 'surveys[@surveymonkey_survey_id].responses_by_page' ],
    configuration_fields: {
      surveymonkey_survey_id: true
    },
    chart_pane_config: {
      span_x: 4,
      span_y: 2,
      layout: 'funnel',
      statistics: { id: 'surveys[@surveymonkey_survey_id].responses_by_page', diffs: 'dw' },
      funnel: {
        autoGroup: true,
        groupingLabelSingular: 'Page # %a',
        groupingLabelPlural: 'Pages # %a to %z'
      }
    }

  view :responses_by_page_bar,
    statistics: [ 'surveys[@surveymonkey_survey_id].responses_by_page' ],
    configuration_fields: {
      surveymonkey_survey_id: true
    },
    chart_pane_config: {
      span_x: 4,
      span_y: 2,
      layout: 'bar',
      statistics: { id: 'surveys[@surveymonkey_survey_id].responses_by_page', diffs: 'dw' },
      bar: {
        autoGroup: true,
        groupingLabelSingular: 'Page # %a',
        groupingLabelPlural: 'Pages # %a to %z'
      }
    }

  view :recent_responders,
    statistics: [ 'surveys[@surveymonkey_survey_id].recent_responders' ],
    configuration_fields: {
      surveymonkey_survey_id: true,
    },
    chart_pane_config: {
      span_x: 3,
      span_y: 2,
      layout: 'table',
      empty: 'No respondents were found for that survey.',
      source: { id: 'surveys[@surveymonkey_survey_id].recent_responders' },
      table: {
        columns: [
          {
            label: 'Responder',
            primary: { type: 'value', source: { id: 'display_name' }, url: { id: 'analysis_url' } },
            secondary: { type: 'value', source: { id: 'date_modified' } }
          },
          {
            label: 'Status',
            primary: { type: 'value', source: { id: 'status_label' } }
          }
        ]
      }
    }

  view :recent_surveys,
    statistics: [ 'recent_surveys' ],
    chart_pane_config: {
      span_x: 4,
      span_y: 2,
      layout: 'table',
      empty: 'No survey found.',
      source: { id: 'recent_surveys' },
      table: {
        columns: [
          {
            primary: { type: 'value', source: { id: 'name' }, url: { id: 'analysis_url' } },
            secondary: { type: 'value', source: { id: 'date_created' } }
          },
          {
            label: 'Responses',
            primary: { type: 'value', source: { id: 'num_responses' } },
          },
          {
            label: 'Status',
            primary: { type: 'value', source: { id: 'is_open' } },
          }
        ]
      }
    }

  processor :get_recent_surveys,
            statistics: [ 'recent_surveys' ]

  processor :get_responses_by_day,
            statistics: [ 'surveys[@surveymonkey_survey_id].response_total' ]

  processor :get_responses_by_question_and_page,
            statistics: [ 'surveys[@surveymonkey_survey_id].responses_by_question',
                          'surveys[@surveymonkey_survey_id].responses_by_page' ]

  processor :get_recent_responders,
            statistics: [ 'surveys[@surveymonkey_survey_id].recent_responders' ]

  processor :survey_details,
            statistics: [ 
              'surveys[@surveymonkey_survey_id].name',
              'surveys[@surveymonkey_survey_id].status',
              'surveys[@surveymonkey_survey_id].created_at',
              'surveys[@surveymonkey_survey_id].num_questions',
              'surveys[@surveymonkey_survey_id].num_pages',
              'surveys[@surveymonkey_survey_id].num_responses'
            ]

  processor :survey_completeness,
            statistics: [ 
              'surveys[@surveymonkey_survey_id].num_complete',
              'surveys[@surveymonkey_survey_id].num_incomplete',
              'surveys[@surveymonkey_survey_id].pct_complete',
              'surveys[@surveymonkey_survey_id].pct_incomplete',
              'surveys[@surveymonkey_survey_id].analysis_url'
            ]

  around_processor :catch_errors

  def computed_view_name(view)
    return nil if @remote_authentication.nil? or view.config.nil? or view.config['surveymonkey_survey_id'].nil? or @remote_authentication.state_config['surveys'].nil?
    @remote_authentication.state_config['surveys'].each do |p|
      return p['name'] if p['id'] == view.config['surveymonkey_survey_id']
    end
    nil
  end

  def get_state_config(opts = {})
    config = {}
    config[:surveys] = get_survey_list({fields: ['title', 'num_responses']}).map { |s| 
      { id: s['survey_id'], name: s['title'], num_responses: s['num_responses'] } 
    }
    config
  end

  private

  # ***********************
  # PROCESSORS

  def get_recent_surveys(data, view_config, options)
    return if data.has_key?('recent_surveys') &&
              !options[:refresh]
    recent_surveys = []

    get_survey_list({
      start_date: (options[:start_time] - 30.days).to_formatted_s(:db),
      page_size: MAX_RECENT_SURVEYS
    }).each do |survey|
      survey_data = {
        id: identifier(survey['survey_id']),
        name: string(survey['title']),
        date_created: datetime(survey['date_created'].to_s),
        num_responses: integer(survey['num_responses'], { archive: true, strategy: Ruminant::DS_STATIC }),
        analysis_url: string(survey['analysis_url']),
        # [TODO] this should probably be renamed "status", because
        # that's the kind of information it contains and that the UI reports on
        is_open: string( open_survey?(survey['survey_id']) ? 'Open' : 'Closed')
      }
      recent_surveys << survey_data
    end

    data['recent_surveys'] = collection(recent_surveys)
  end

  def get_responses_by_day(data, view_config, options)
    return if view_config['surveymonkey_survey_id'].nil?
    data['surveys'] ||= collection([])

    survey_data = get_survey_data_from_collection(view_config['surveymonkey_survey_id'], data)

    return if survey_data.has_key?('response_total') && !options[:refresh]
    respondents = get_respondents({ start_modified_date: options[:start_time].to_formatted_s(:db),
                                     end_modified_date: (options[:end_time] + 1.second).to_formatted_s(:db) })
    survey_data['response_total'] = integer(respondents.count, { archive: true, strategy: Ruminant::DS_INTERVAL })
    update_collection_member(data['surveys'], @surveymonkey_survey_id, survey_data)
  end

  def get_responses_by_question_and_page(data, view_config, options)
    return if view_config['surveymonkey_survey_id'].nil?
    data['surveys'] ||= collection([])

    survey_data = get_survey_data_from_collection(view_config['surveymonkey_survey_id'], data)

    return if survey_data.has_key?('responses_by_question') &&
              survey_data.has_key?('responses_by_page') &&
              !options[:refresh]

    respondents = get_respondents
    responses_per_question, responses_per_page = configure_responses(respondents)
    survey_data['responses_by_question'] = get_responses_dynamic_group(responses_per_question)
    survey_data['responses_by_page'] = get_responses_dynamic_group(responses_per_page, :num_responders)
    update_collection_member(data['surveys'], @surveymonkey_survey_id, survey_data)
  end

  def get_recent_responders(data, view_config, options)
    return if view_config['surveymonkey_survey_id'].nil?
    data['surveys'] ||= collection([])

    survey_data = get_survey_data_from_collection(view_config['surveymonkey_survey_id'], data)

    return if survey_data.has_key?('recent_responders') && !options[:refresh]

    result = []
    rr = get_respondents({ fields: %w(
                             analysis_url
                             collection_mode
                             collector_id
                             custom_id
                             date_modified
                             date_start
                             email
                             first_name
                             last_name
                             ip_address
                             recipient_id
                             status
                           ),
                           order_by: "date_modified" })
    rr.each do |r|
      display_name = r['respondent_id']

      if !r['email'].blank?
        display_name = r['email']
      elsif !r['first_name'].blank? && !r['last_name'].blank?
        display_name = "#{r['first_name']} #{r['last_name']}"
      elsif !r['first_name'].blank?
        display_name = r['first_name']
      elsif !r['last_name'].blank?
        display_name = r['last_name']
      end

      status_labels = {
        'partial' => 'Incomplete',
        'completed' => 'Complete'
      }

      result << {
        "id" => string(r['respondent_id']),
        "display_name" => string(display_name),
        "first_name" => url(r['first_name']),
        "last_name" => url(r['last_name']),
        "email" => url(r['email']),
        "analysis_url" => url(r['analysis_url']),
        "date_modified" => datetime(r['date_modified']),
        "collection_mode" => string(r['collection_mode']),
        "status" => string(r['status']),
        "status_label" => string(status_labels[r['status']] || r['status'])
      }
    end

    survey_data['recent_responders'] = collection(result)
    update_collection_member(data['surveys'], @surveymonkey_survey_id, survey_data)
  end

  def survey_completeness(data, view_config, options)
    return if view_config['surveymonkey_survey_id'].nil?
    data['surveys'] ||= collection([])

    survey_data = get_survey_data_from_collection(view_config['surveymonkey_survey_id'], data)

    return if survey_data.has_key?('num_complete') &&
              survey_data.has_key?('num_incomplete') &&
              survey_data.has_key?('pct_complete') &&
              survey_data.has_key?('pct_incomplete') &&
              survey_data.has_key?('analysis_url') &&
              !options[:refresh]

    collectors = get_collectors_list( @surveymonkey_survey_id )
    survey_details = get_survey_details(@surveymonkey_survey_id)

    num_incomplete = 0
    num_complete = 0
    num_responses = ((survey_details.is_a?(Hash) and survey_details.has_key?('num_responses')) ? survey_details['num_responses'] : 0)

    collectors.each do |c|
      cnts = get_response_counts(c["collector_id"])
      next unless cnts
      num_incomplete   += cnts["started"]
      num_complete += cnts["completed"]
    end

    survey_data['analysis_url']= string(get_survey_list( {title: survey_data['name']['v']} )[0]['analysis_url'] )
    survey_data['num_complete']= integer(num_complete, { archive: true, strategy: Ruminant::DS_STATIC })
    survey_data['num_incomplete']= integer(num_incomplete, { archive: true, strategy: Ruminant::DS_STATIC })

    survey_data['pct_incomplete'] = percentage(percent_of(num_incomplete, num_responses), { archive: true, strategy: Ruminant::DS_STATIC })
    survey_data['pct_complete'] = percentage(percent_of(num_complete, num_responses), { archive: true, strategy: Ruminant::DS_STATIC })

    update_collection_member(data['surveys'], @surveymonkey_survey_id, survey_data)
  end

  def survey_details(data, view_config, options)
    return if view_config['surveymonkey_survey_id'].nil?
    data['surveys'] ||= collection([])

    survey_data = get_survey_data_from_collection(view_config['surveymonkey_survey_id'], data)

    return if survey_data.has_key?('name') &&
              survey_data.has_key?('status') &&
              survey_data.has_key?('created_at') &&
              survey_data.has_key?('num_questions') &&
              survey_data.has_key?('num_pages') &&
              survey_data.has_key?('num_responses') &&
              !options[:refresh]
    details = {}
    s_details = get_survey_details(@surveymonkey_survey_id)
    return if s_details.nil?

    survey_data['status']       = string(open_survey?(@surveymonkey_survey_id) ? "Open" : "Closed")
    survey_data['created_at']   = datetime(s_details['date_created'])
    survey_data['num_questions']= integer(s_details['question_count'])
    survey_data['num_pages']    = integer(s_details['pages'].length)
    survey_data['num_responses']= integer(s_details['num_responses'], { archive: true, strategy: Ruminant::DS_STATIC })
    update_collection_member(data['surveys'], @surveymonkey_survey_id, survey_data)
  end

  def get_survey_data_from_collection(surveymonkey_survey_id, data)
    @surveymonkey_survey_id = surveymonkey_survey_id
    survey = get_survey_from_state_config(@surveymonkey_survey_id)

    raise Ruminant::ProfileInvalidException.new("SurveyMonkey survey #{@surveymonkey_survey_id} not found") if survey.nil?

    update_collection_member(data['surveys'], @surveymonkey_survey_id, {
      'id' => identifier(@surveymonkey_survey_id),
      'name' => string(survey['name'])
    })
  end

  def get_respondents(options = {})
    body_params = { survey_id: @surveymonkey_survey_id,
                    page_size: 1000 }.merge(options)

    return get_responders_list( body_params )
  end

  def configure_responses(respondents)
    responses_per_question = {}
    responses_per_page = {}

    survey_details = get_survey_details(@surveymonkey_survey_id)
    return [ responses_per_question, responses_per_page ] if survey_details.nil? or survey_details['pages'].nil?

    survey_details['pages'].each do |page|
      responses_per_page[page['page_id']] = { heading: page['heading'],
                                              num_responses: 0,
                                              position: page['position'],
                                              responders: [],
                                              num_responders: 0 }
      page['questions'].each do |question|
        responses_per_question[question['question_id']] = { heading: question['heading'],
                                                            num_responses: 0,
                                                            page: page['page_id'],
                                                            position: page['position']*PAGE_MULTIPLIER + question['position'] }
      end
    end

    if respondents.count > 0
      params = { respondent_ids: respondents.collect{|respondent| respondent["respondent_id"]},
                 survey_id: @surveymonkey_survey_id }
      responses = auth_adapter.get_responses(params)

      if responses.is_a?(Array)
        responses.each do |response|
          response['questions'].each do |question|
            responses_per_question[question['question_id']][:num_responses] += 1
            page_id = responses_per_question[question['question_id']][:page]

            # Track total responses
            responses_per_page[page_id][:num_responses] += 1

            # Track responders
            unless responses_per_page[page_id][:responders].member?(response['respondent_id'])
              responses_per_page[page_id][:responders] << response['respondent_id']
            end

            responses_per_page[page_id][:num_responders] = responses_per_page[page_id][:responders].length
          end
        end
      end
    end

    [ responses_per_question, responses_per_page ]
  end

  def get_responses_dynamic_group(responses_result, value_key = :num_responses)
    dynamic_group(responses_result.keys.map do |key|
      value_params = { label: responses_result[key][:heading], archive: true, strategy: Ruminant::DS_STATIC }
      value_params[:order] = responses_result[key][:position] unless responses_result[key][:position].nil?
      {
        'id' => identifier(key),
        'name' => string(responses_result[key][:heading]),
        'value' => integer(responses_result[key][value_key], value_params)
      }
    end)
  end

  def get_survey_from_state_config(survey_id)
    @remote_authentication.state_config['surveys'].select { |survey|
      survey['id'] == survey_id
    }.first
  end


  # An around filter to catch general API errors and throw the Ruminant equivalent
  def catch_errors(data = nil, view_config = nil, options = nil)
    begin
      yield

    rescue Rester::UnprocessableEntityException => e
      raise Ruminant::DataInvalidException.new(e.message)

    rescue Rester::AccessDeniedException => e
      raise Ruminant::AuthInvalidException.new(e.message)
    end
  end

  def open_survey?(survey_id)
    c_list = get_collectors_list( survey_id, { fields: ["open"] } )
    return !!c_list.find{ |collector| collector['open'] }
  end

  def auth_adapter
    @remote_authentication.provider_auth_adapter
  end

  # ***********************
  # FETCHERS

  def get_responders_list( params )
    get_list_from_api( :get_respondent_list, 'respondents', params )
  end

  def get_collectors_list( s_id, opts={} )
    body_params = { 
                  survey_id: s_id,
                  page_size: 1000,
                }.merge(opts)
    get_list_from_api( :get_collector_list, 'collectors', body_params )
  end

  def get_survey_list(opts = {})
    options = { 
                page_size: 1000,
                fields: ['title', 'analysis_url', 'date_created', 'num_responses']
              }.merge(opts)
    get_list_from_api( :get_survey_list, 'surveys', options )
  end

  def get_list_from_api( api_method_name, data_key, req_params )
    page = 1
    next_page = nil
    result = []
    begin
      loop do
        api_data = auth_adapter.send(api_method_name, req_params.merge({ page: page }))
        break if api_data.nil? or !api_data[data_key].is_a?(Array)
        result += api_data[data_key]
        break unless(api_data[data_key].count == api_data['page_size'])
        page += 1
      end
    rescue Rester::NotFoundException => e
      raise Ruminant::InsufficientAccessException.new(e.message)
    end
    result    
  end

  def get_response_counts( collect_id )
    auth_adapter.get_response_counts({ "collector_id" => collect_id})
  end

  def get_survey_details(s_id)
    auth_adapter.get_survey_details({ "survey_id" => s_id})
  end
end
