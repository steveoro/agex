# Load the rails application
require File.expand_path('../application', __FILE__)

require 'framework/version'


# -- AgeX-specific stuff: --

AGEX_FRAMEWORK_VERSION  = Version::FULL unless defined? AGEX_FRAMEWORK_VERSION
AGEX_APP                = 'agex' unless defined? AGEX_APP
AGEX_APP_NAME           = 'AgeX 5' unless defined? AGEX_APP_NAME
AGEX_APP_LOGO           = 'agex5_logo.png' unless defined? AGEX_APP_LOGO

AGEX_FEATURES = {
#  (configure here additional features) 
} unless defined?(AGEX_FEATURES)

LOCALES = {'it' => 'it-IT', 'en' => 'en-US'}.freeze

# Set this to false to enable the self-destruct sequence on application timeout expiring.
DISABLE_SELF_DESTRUCT = true unless defined?(DISABLE_SELF_DESTRUCT)
# ---------------------------------------------------------------------------


# Format string according to ExtJS4's Ext.form.field.Date
# Should match the format below and should be easily sortable.
#
AGEX_FILTER_DATE_FORMAT_EXTJS  = 'Y-m-d';

# Format string used for both SQL's WHERE-clause and Ruby's strftime().
# Should match the format above and should be easily sortable.
#
AGEX_FILTER_DATE_FORMAT_SQL    = '%Y-%m-%d';
# ----------------------------------------------------------------------------


Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8


# Initialize the rails application
Agex5::Application.initialize!
