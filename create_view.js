/* global
  CreateProviderSuggestionModal,
  CreateSupportTicketModal,
  EditViewModal,
  FormModalBase,
  HandlebarsTemplates,
  View
*/

var CreateViewModal = FormModalBase.extend({
  template: HandlebarsTemplates['modals/create_view'],

  events: {
    'click .select-provider ul li.selectable': 'selectProvider',
    'click .select-view-type button': 'selectViewType',
    'click .create-provider-suggestion': 'createProviderSuggestion',
    'click .create-support-ticket': 'createSupportTicket',
    'click .submit': 'submit'
  },

  afterRender: function () {
    if (this.options && this.options.provider) {
      this.$('.select-provider ul li[data-provider="' + this.options.provider + '"]').trigger('click');
    }

    this.app.trigger('trackMetricEvent', 'insightLibraryOpened', { source: this.options.source });

    this.doubleWide();
  },

  createSupportTicket: function (e) {
    var source = 'New Insight' + ((this.provider) ? ' - ' + this.provider.get('id') : '');
    e.preventDefault();
    this.close();
    this.app.initializeModal(CreateSupportTicketModal, { source: source });
  },

  createProviderSuggestion: function (e) {
    e.preventDefault();
    this.close();
    this.app.initializeModal(CreateProviderSuggestionModal);
  },

  selectViewType: function (e) {
    this.viewType = $(e.currentTarget).data('view-type');
    this.submit();
  },

  selectProvider: function (e) {
    var $providers = this.$('ul li').removeClass('selected').addClass('masked'),
        $elm = $(e.currentTarget).addClass('selected').removeClass('masked'),
        $section = this.$('.modal-section').addClass('provider-selected'),
        $viewTypes = this.$('.view-types').html('').scrollTop(0);

    this.provider = this.app.shared('providers').get($elm.data('provider'));

    this.provider.get('view_types').forEach(function (viewType) {
      var edge = viewType.edge;

      if (!edge || (edge && this.app.shared('edge'))) {
        $viewTypes.append($('<li></li>').html(
          HandlebarsTemplates['modals/create_view/view_type']({ provider: this.provider, viewType: viewType })
        ));
      }
    }.bind(this));
  },

  submit: function () {
    var view = new View({
      report_id: this.app.shared('report').get('id'),
      provider: this.provider.get('id'),
      view_type: this.viewType,
      source: this.options.source,
      grid_x: 1,
      grid_y: 1
    });

    this.unapplyErrors();

    view.save(null, {
      wait: true,
      success: function () {
        this.close();
        this.app.trigger('scrollToTop');
        this.app.trigger('trackMetricEvent', 'insightCreated', {
          provider: view.get('provider'),
          insight_type: view.get('view_type'),
          source: view.get('source')
        });
        
        this.app.trigger('trackMetricEvent', view.get('provider') + 'InsightCreated', {
          provider: view.get('provider'),
          insight_type: view.get('view_type'),
          source: view.get('source')
        });
        // If a remote authentication was created automatically, the EditViewModal
        // depends on it being present in the shared remoteAuthentications collection
        // immediately.
        if (view.get('remote_authentication')) {
          this.app.shared('remoteAuthentications').add(view.get('remote_authentication'));
        }

        this.app.initializeModal(EditViewModal, { view: view });

        if (this.options && this.options.onCreate) {
          this.options.onCreate();
        }
      }.bind(this),
      error: function (model, response, options) {
        this.applyErrors(response);
      }.bind(this),
    });
  }
});
