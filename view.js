/* global
  BaseCollection,
  BaseModel,
  ChartPane
*/

var View = BaseModel.extend({
  exports: [
    'errorDetails',
    'isCustom',
    'isUtility',
    'isInvalid',
    'isProfileInvalid',
    'isConfigurationInvalid',
    'isViewTypeConfigurable',
    'isRefreshable',
    'isRenderable',
    'isResizable',
    'isSample',
    'hasDetailsModal',
    'supportsCustomRanges',
    'viewTypeDescription',
    'computedColor',
    'computedIcon'
  ],

  /* url builder */

  url: function (resourceOnly) {
    var app = window.app;

    return '/api/organizations/' +
      app.shared('organization').get('id') + '/reports/' +
      ((this.get('report_id')) ? this.get('report_id') : app.shared('report').get('id')) + '/views' +
      ((this.get('id')) ? '/' + this.get('id') : '') +
      ((resourceOnly) ? '' : '?date=' + app.shared('filter').dateString + '&range=' + app.shared('filter').range);
  },

  /* error utilities */

  errorDetails: function () {
    var status = this.get('view_status'),
        errorCode = this.get('last_error_code'),
        publicMessage = this.get('last_error_public_message'),
        message = null,
        action = null;

    // remote authentication errors

    if (status === 'error' && errorCode === 'auth_invalid') {
      action = 'fix-remote-authentication';

      if (this.isCustom()) {
        message = 'We don\'t have permission to access the specified data URL.';
      }
      else {
        message = 'Unable to log in.';
      }
    }

    else if (status === 'error' && errorCode === 'auth_invalid' && this.isCustom()) {
      message = 'We don\'t have permission to access the specified data URL.';
      action = 'fix-view';
    }

    else if (status === 'error' && errorCode === 'data_invalid' && !this.isCustom()) {
      message = 'Unable to read data.';
    }

    else if (status === 'error' && errorCode === 'data_invalid' && this.isCustom()) {
      message = 'Unable to parse custom data.';
      action = 'try-refresh-view';
    }

    else if (status === 'error' && errorCode === 'insufficient_access') {
      message = 'Account cannot be accessed with provided credentials.';
      action = 'fix-view';
    }

    else if (status === 'error' && errorCode === 'failed') {
      message = 'We encountered a temporary error.';
    }

    // view errors

    else if (status === 'configure') {
      message = 'This insight is not connected yet.';
      action = 'connect-view';
    }

    else if (status === 'error' && errorCode === 'configuration_invalid') {
      message = publicMessage || 'Unable to use configuration.';
      action = 'fix-view';
    }

    else if (status === 'error' && errorCode === 'profile_invalid') {
      message = publicMessage || 'The account or profile you selected is no longer available.';
      action = 'fix-view';
    }

    else if (status === 'disabled') {
      message = 'Linked account has been disabled.';
      action = 'fix-remote-authentication';
    }

    else {
      message = "We encountered a temporary error.";
    }

    return {
      message: message,
      action: action
    };
  },

  /* refresh tasks */

  refreshSnapshots: function () {
    return this.refreshTask('snapshots');
  },

  /* misc */

  provider: function () {
    return window.app.shared('providers').get(this.get('provider'));
  },

  /* conditionals */

  supportsCustomRanges: function () {
    return (this.get('view_config').supported_ranges.indexOf(1) !== -1);
  },

  hasDetailsModal: function () {
    var provider = this.provider();

    return !provider.get('sample') && (provider.get('namespace') !== 'custom') && (provider.get('namespace') !== 'utility');
  },

  isProfileInvalid: function () {
    return this.get('view_status') === 'error' && this.get('last_error_code') === 'profile_invalid';
  },

  isConfigurationInvalid: function () {
    return this.get('view_status') === 'error' && this.get('last_error_code') === 'configuration_invalid';
  },

  isRefreshable: function () {
    if (

      // View has a remote authentication
      !!this.get('remote_authentication_id') &&

      // We're viewing the current day
      window.app.shared('filter').isToday &&

      // View is not in "updating" state
      (this.get('view_status') !== 'updating') &&

      // Not in public mode
      !window.app.shared('publicMode') &&

      // Exclude utilities
      !this.isUtility() &&

      // Exclude sample
      !this.isSample()

    ) {
      return true;
    }
    else {
      return false;
    }
  },

  // If view is acceptable for rendering
  isRenderable: function () {
    var status = this.get('view_status'),
        errorCode = this.get('last_error_code');

    // Auth, config or profile invalid -- never attempt render
    if (status === 'error' && [ 'auth_invalid', 'configuration_invalid', 'profile_invalid' ].indexOf(errorCode) !== -1) {
      return false;
    }
    else if ([ 'configure', 'disabled' ].indexOf(this.get('view_status')) !== -1) {
      return false;
    }
    else if (!this.hasSufficientData()) {
      return false;
    }
    else {
      return true;
    }
  },

  // Whether or not view has sufficient data to call ChartPane
  hasSufficientData: function () {
    return !!this.get('snapshot') || !!this.get('view_config').snapshot_disabled;
  },

  // Whether or not the chartpane config supports resizing
  isResizable: function () {
    return !!(this.chartPaneConfig().layout);
  },

  isCustom: function () {
    return (this.get('provider') === 'custom');
  },

  isUtility: function () {
    return (this.get('provider') === 'utility');
  },

  isSample: function () {
    return !!this.providerProperty('sample');
  },

  isInvalid: function () {
    return (this.get('view_status') !== 'ok');
  },

  isViewTypeConfigurable: function () {
    var provider = this.provider();

    return (provider && provider.get('view_types'));
  },

  /* computed properties */

  providerProperty: function (property) {
    var provider = this.provider();
    return (provider) ? provider.get(property) : undefined;
  },

  computedColor: function () {
    var provider = this.provider(),
        viewColor = this.get('color'),
        viewConfigColor = (this.get('view_config') || {}).color,
        providerColor = provider.get('color');

    function translate (color) {
      var matches = color.match(/^\@(.+)$/);

      if (matches) {
        return window.app.shared('providers').get(matches[1]).get('color');
      }
      else {
        return color;
      }
    }

    if (viewColor) {
      return translate(viewColor);
    }
    else if (viewConfigColor) {
      return translate(viewConfigColor);
    }
    else {
      return translate(providerColor);
    }
  },

  computedIcon: function () {
    var provider = this.provider(),
        viewConfigIcon = (this.get('view_config') || {}).icon,
        providerIcon = provider.get('icon');

    function translate (icon) {
      var matches = String(icon).match(/^\@(.+)$/);

      if (matches) {
        return window.app.shared('providers').get(matches[1]).get('icon');
      }
      else {
        return icon;
      }
    }

    if (viewConfigIcon) {
      return translate(viewConfigIcon);
    }
    else {
      return translate(providerIcon);
    }
  },

  computedConfigurationFields: function (forViewType) {
    var viewTypeId = forViewType || this.get('view_type'),
        viewConfig = this.get('view_config'),
        viewType = this.provider().getViewType(viewTypeId),
        provider = this.provider(),
        config = this.get('config'),
        cpConfig,
        scopeConfig = null,
        layoutConfig = null,
        fields = [],
        value,
        add,
        addViewAttribute;


    add = function (inField) {
      fields.push(inField);
    }.bind(this);

    addViewAttribute = function (attribute) {
      add({
        category: 'view',
        name: 'view.' + attribute,
        required: false,
        type: 'view',
        value: this.get(attribute)
      });
    }.bind(this);

    // Standard view options - attributes of view model
    [ 'custom_url' ].forEach(function(attr) {
      if (provider.get('modify_view_' + attr)) {
        addViewAttribute(attr);
      }
    }.bind(this));

    if (viewConfig) {
      scopeConfig = viewType.scope;
      cpConfig = viewType.chart_pane_config;
      layoutConfig = ChartPane.Layout.get(cpConfig.layout).configurables();

      // Scope options - defined in view declaration
      for (var f in scopeConfig) {
        var cfg = {
          category: 'scope',
          label: scopeConfig[f].label,
          name: 'scope.' + f,
          required: !!scopeConfig[f].required,
          validate: !!scopeConfig[f].validate,
          retrieve: !!scopeConfig[f].retrieve,
          type: scopeConfig[f].type,
          control: scopeConfig[f].control,
          source: scopeConfig[f].source,
          value: value
        };

        // Metadata from flex fields
        if (config && config.meta && config.meta[cfg.name]) {
          cfg.meta = config.meta[cfg.name];
        }

        // Scope value
        if (config && config.scope) {
          cfg.value = config.scope[f];
        }

        // Legacy mapping of custom_url value
        if (f === 'url' && !value) {
          cfg.value = cfg.value || this.get('custom_url');
        }

        if (scopeConfig[f].dependant) {
          cfg.dependant = 'scope.' + scopeConfig[f].dependant;
        }

        if (scopeConfig[f].placeholder) {
          cfg.placeholder = scopeConfig[f].placeholder;
        }

        add(cfg);
      }

      // Layout options - defined in chart pane layout
      if (cpConfig.configurable) {
        for (var i = 0; i < layoutConfig.length; i += 1) {
          if (config && config.layout) {
            value = config.layout[layoutConfig[i].name];
          }
          else {
            value = null;
          }

          add({
            category: 'layout',
            label: layoutConfig[i].label,
            name: 'layout.' + layoutConfig[i].name,
            required: true,
            defaultValue: layoutConfig[i].defaultValue,
            options: layoutConfig[i].options,
            type: layoutConfig[i].type,
            value: value
          });
        }
      }
    }

    // Standard view options - attributes of view model
    [ 'name', 'description', 'color' ].forEach(function(attr) {
      if (provider.get('modify_view_' + attr)) {
        addViewAttribute(attr);
      }
    }.bind(this));

    return fields;
  },

  /* misc */

  viewTypeDescription: function () {
    return this.get('view_config').description;
  },

  spanX: function () {
    return this.get('span_x') || this.chartPaneConfig().span_x;
  },

  spanY: function () {
    return this.get('span_y') || this.chartPaneConfig().span_y;
  },

  chartPaneConfig: function () {
    return this.get('view_config').chart_pane_config || {};
  }

});

var ViewCollection = BaseCollection.extend({
  model: View,
  comparator: 'grid_y',

  parse: function (response, options) {
    var snapshots = {},
        views = [];

    response.snapshots.forEach(function (snapshot) {
      snapshots[snapshot.remote_authentication_id] = snapshot.snapshot;
    });

    response.views.forEach(function (view) {
      if (view.remote_authentication_id) {
        view.snapshot = snapshots[view.remote_authentication_id];
      }

      views.push(view);
    });

    return views;
  },

  url: function () {
    return '/api/organizations/' +
      window.app.shared('organization').get('id') + '/reports/' +
      window.app.shared('report').get('id') + '/presentation';
  }
});
