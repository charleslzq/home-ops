job "robin" {
  datacenters = ["roger"]
  type = "service"

  vault {
    policies = ["${policy}"]
  }

  group "synapse" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2c"
    }
    network {
      mode = "bridge"
      port "http" {
        to = 8008
      }
    }
    volume "host" {
      type      = "host"
      source    = "host"
      read_only = false
    }

    service {
      name = "robin"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "db-robin"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "synapse-server" {
      driver = "docker"

      config {
        image = "matrixdotorg/synapse:latest"
        ports = ["http"]
        volumes = [
          "/opt/nomad/volume/robin/data:/data",
          "secrets/homeserver.yaml:/data/homeserver.yaml",
          "local/log_config:/data/robin.zenq.me.log.config",
          "secrets/signing_key:/data/robin.zenq.me.signing.key",
        ]
      }

      env {
        SYNAPSE_SERVER_NAME = "robin.zenq.me"
        SYNAPSE_REPORT_STATS = "no"
      }

      template {
        data = <<EOH
# Configuration file for Synapse.
#
# This is a YAML file: see [1] for a quick introduction. Note in particular
# that *indentation is important*: all the elements of a list or dictionary
# should have the same indentation.
#
# [1] https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html


## Modules ##

# Server admins can expand Synapse's functionality with external modules.
#
# See https://matrix-org.github.io/synapse/latest/modules.html for more
# documentation on how to configure or create custom modules for Synapse.
#
modules:
    # - module: my_super_module.MySuperClass
    #   config:
    #       do_thing: true
    # - module: my_other_super_module.SomeClass
    #   config: {}


## Server ##

# The public-facing domain of the server
#
# The server_name name will appear at the end of usernames and room addresses
# created on this server. For example if the server_name was example.com,
# usernames on this server would be in the format @user:example.com
#
# In most cases you should avoid using a matrix specific subdomain such as
# matrix.example.com or synapse.example.com as the server_name for the same
# reasons you wouldn't use user@email.example.com as your email address.
# See https://matrix-org.github.io/synapse/latest/delegate.html
# for information on how to host Synapse on a subdomain while preserving
# a clean server_name.
#
# The server_name cannot be changed later so it is important to
# configure this correctly before you start Synapse. It should be all
# lowercase and may contain an explicit port.
# Examples: matrix.org, localhost:8080
#
server_name: "robin.zenq.me"

# When running as a daemon, the file to store the pid in
#
pid_file: /data/homeserver.pid

# The absolute URL to the web client which /_matrix/client will redirect
# to if 'webclient' is configured under the 'listeners' configuration.
#
# This option can be also set to the filesystem path to the web client
# which will be served at /_matrix/client/ if 'webclient' is configured
# under the 'listeners' configuration, however this is a security risk:
# https://github.com/matrix-org/synapse#security-note
#
#web_client_location: https://riot.example.com/

# The public-facing base URL that clients use to access this Homeserver (not
# including _matrix/...). This is the same URL a user might enter into the
# 'Custom Homeserver URL' field on their client. If you use Synapse with a
# reverse proxy, this should be the URL to reach Synapse via the proxy.
# Otherwise, it should be the URL to reach Synapse's client HTTP listener (see
# 'listeners' below).
#
#public_baseurl: https://example.com/

# Set the soft limit on the number of file descriptors synapse can use
# Zero is used to indicate synapse should set the soft limit to the
# hard limit.
#
#soft_file_limit: 0

# Presence tracking allows users to see the state (e.g online/offline)
# of other local and remote users.
#
presence:
  # Uncomment to disable presence tracking on this homeserver. This option
  # replaces the previous top-level 'use_presence' option.
  #
  #enabled: false

# Whether to require authentication to retrieve profile data (avatars,
# display names) of other users through the client API. Defaults to
# 'false'. Note that profile data is also available via the federation
# API, unless allow_profile_lookup_over_federation is set to false.
#
#require_auth_for_profile_requests: true

# Uncomment to require a user to share a room with another user in order
# to retrieve their profile information. Only checked on Client-Server
# requests. Profile requests from other servers should be checked by the
# requesting server. Defaults to 'false'.
#
#limit_profile_requests_to_users_who_share_rooms: true

# Uncomment to prevent a user's profile data from being retrieved and
# displayed in a room until they have joined it. By default, a user's
# profile data is included in an invite event, regardless of the values
# of the above two settings, and whether or not the users share a server.
# Defaults to 'true'.
#
#include_profile_data_on_invite: false

# If set to 'true', removes the need for authentication to access the server's
# public rooms directory through the client API, meaning that anyone can
# query the room directory. Defaults to 'false'.
#
#allow_public_rooms_without_auth: true

# If set to 'true', allows any other homeserver to fetch the server's public
# rooms directory via federation. Defaults to 'false'.
#
#allow_public_rooms_over_federation: true

# The default room version for newly created rooms.
#
# Known room versions are listed here:
# https://matrix.org/docs/spec/#complete-list-of-room-versions
#
# For example, for room version 1, default_room_version should be set
# to "1".
#
#default_room_version: "6"

# The GC threshold parameters to pass to `gc.set_threshold`, if defined
#
#gc_thresholds: [700, 10, 10]

# The minimum time in seconds between each GC for a generation, regardless of
# the GC thresholds. This ensures that we don't do GC too frequently.
#
# A value of `[1s, 10s, 30s]` indicates that a second must pass between consecutive
# generation 0 GCs, etc.
#
# Defaults to `[1s, 10s, 30s]`.
#
#gc_min_interval: [0.5s, 30s, 1m]

# Set the limit on the returned events in the timeline in the get
# and sync operations. The default value is 100. -1 means no upper limit.
#
# Uncomment the following to increase the limit to 5000.
#
#filter_timeline_limit: 5000

# Whether room invites to users on this server should be blocked
# (except those sent by local server admins). The default is False.
#
#block_non_admin_invites: true

# Room searching
#
# If disabled, new messages will not be indexed for searching and users
# will receive errors when searching for messages. Defaults to enabled.
#
#enable_search: false

# Prevent outgoing requests from being sent to the following blacklisted IP address
# CIDR ranges. If this option is not specified then it defaults to private IP
# address ranges (see the example below).
#
# The blacklist applies to the outbound requests for federation, identity servers,
# push servers, and for checking key validity for third-party invite events.
#
# (0.0.0.0 and :: are always blacklisted, whether or not they are explicitly
# listed here, since they correspond to unroutable addresses.)
#
# This option replaces federation_ip_range_blacklist in Synapse v1.25.0.
#
# Note: The value is ignored when an HTTP proxy is in use
#
#ip_range_blacklist:
#  - '127.0.0.0/8'
#  - '10.0.0.0/8'
#  - '172.16.0.0/12'
#  - '192.168.0.0/16'
#  - '100.64.0.0/10'
#  - '192.0.0.0/24'
#  - '169.254.0.0/16'
#  - '192.88.99.0/24'
#  - '198.18.0.0/15'
#  - '192.0.2.0/24'
#  - '198.51.100.0/24'
#  - '203.0.113.0/24'
#  - '224.0.0.0/4'
#  - '::1/128'
#  - 'fe80::/10'
#  - 'fc00::/7'
#  - '2001:db8::/32'
#  - 'ff00::/8'
#  - 'fec0::/10'

# List of IP address CIDR ranges that should be allowed for federation,
# identity servers, push servers, and for checking key validity for
# third-party invite events. This is useful for specifying exceptions to
# wide-ranging blacklisted target IP ranges - e.g. for communication with
# a push server only visible in your network.
#
# This whitelist overrides ip_range_blacklist and defaults to an empty
# list.
#
#ip_range_whitelist:
#   - '192.168.1.1'

# List of ports that Synapse should listen on, their purpose and their
# configuration.
#
# Options for each listener include:
#
#   port: the TCP port to bind to
#
#   bind_addresses: a list of local addresses to listen on. The default is
#       'all local interfaces'.
#
#   type: the type of listener. Normally 'http', but other valid options are:
#       'manhole' (see https://matrix-org.github.io/synapse/latest/manhole.html),
#       'metrics' (see https://matrix-org.github.io/synapse/latest/metrics-howto.html),
#       'replication' (see https://matrix-org.github.io/synapse/latest/workers.html).
#
#   tls: set to true to enable TLS for this listener. Will use the TLS
#       key/cert specified in tls_private_key_path / tls_certificate_path.
#
#   x_forwarded: Only valid for an 'http' listener. Set to true to use the
#       X-Forwarded-For header as the client IP. Useful when Synapse is
#       behind a reverse-proxy.
#
#   resources: Only valid for an 'http' listener. A list of resources to host
#       on this port. Options for each resource are:
#
#       names: a list of names of HTTP resources. See below for a list of
#           valid resource names.
#
#       compress: set to true to enable HTTP compression for this resource.
#
#   additional_resources: Only valid for an 'http' listener. A map of
#        additional endpoints which should be loaded via dynamic modules.
#
# Valid resource names are:
#
#   client: the client-server API (/_matrix/client), and the synapse admin
#       API (/_synapse/admin). Also implies 'media' and 'static'.
#
#   consent: user consent forms (/_matrix/consent).
#       See https://matrix-org.github.io/synapse/latest/consent_tracking.html.
#
#   federation: the server-server API (/_matrix/federation). Also implies
#       'media', 'keys', 'openid'
#
#   keys: the key discovery API (/_matrix/keys).
#
#   media: the media API (/_matrix/media).
#
#   metrics: the metrics interface.
#       See https://matrix-org.github.io/synapse/latest/metrics-howto.html.
#
#   openid: OpenID authentication.
#
#   replication: the HTTP replication API (/_synapse/replication).
#       See https://matrix-org.github.io/synapse/latest/workers.html.
#
#   static: static resources under synapse/static (/_matrix/static). (Mostly
#       useful for 'fallback authentication'.)
#
#   webclient: A web client. Requires web_client_location to be set.
#
listeners:
  # TLS-enabled listener: for when matrix traffic is sent directly to synapse.
  #
  # Disabled by default. To enable it, uncomment the following. (Note that you
  # will also need to give Synapse a TLS key and certificate: see the TLS section
  # below.)
  #
  #- port: 8448
  #  type: http
  #  tls: true
  #  resources:
  #    - names: [client, federation]

  # Unsecure HTTP listener: for when matrix traffic passes through a reverse proxy
  # that unwraps TLS.
  #
  # If you plan to use a reverse proxy, please see
  # https://matrix-org.github.io/synapse/latest/reverse_proxy.html.
  #
  - port: 8008
    tls: false
    type: http
    x_forwarded: true

    resources:
      - names: [client, federation]
        compress: false

    # example additional_resources:
    #
    #additional_resources:
    #  "/_matrix/my/custom/endpoint":
    #    module: my_module.CustomRequestHandler
    #    config: {}

  # Turn on the twisted ssh manhole service on localhost on the given
  # port.
  #
  #- port: 9000
  #  bind_addresses: ['::1', '127.0.0.1']
  #  type: manhole

# Connection settings for the manhole
#
manhole_settings:
  # The username for the manhole. This defaults to 'matrix'.
  #
  #username: manhole

  # The password for the manhole. This defaults to 'rabbithole'.
  #
  #password: mypassword

  # The private and public SSH key pair used to encrypt the manhole traffic.
  # If these are left unset, then hardcoded and non-secret keys are used,
  # which could allow traffic to be intercepted if sent over a public network.
  #
  #ssh_priv_key_path: /data/id_rsa
  #ssh_pub_key_path: /data/id_rsa.pub

# Forward extremities can build up in a room due to networking delays between
# homeservers. Once this happens in a large room, calculation of the state of
# that room can become quite expensive. To mitigate this, once the number of
# forward extremities reaches a given threshold, Synapse will send an
# org.matrix.dummy_event event, which will reduce the forward extremities
# in the room.
#
# This setting defines the threshold (i.e. number of forward extremities in the
# room) at which dummy events are sent. The default value is 10.
#
#dummy_events_threshold: 5


## Homeserver blocking ##

# How to reach the server admin, used in ResourceLimitError
#
#admin_contact: 'mailto:admin@server.com'

# Global blocking
#
#hs_disabled: false
#hs_disabled_message: 'Human readable reason for why the HS is blocked'

# Monthly Active User Blocking
#
# Used in cases where the admin or server owner wants to limit to the
# number of monthly active users.
#
# 'limit_usage_by_mau' disables/enables monthly active user blocking. When
# enabled and a limit is reached the server returns a 'ResourceLimitError'
# with error type Codes.RESOURCE_LIMIT_EXCEEDED
#
# 'max_mau_value' is the hard limit of monthly active users above which
# the server will start blocking user actions.
#
# 'mau_trial_days' is a means to add a grace period for active users. It
# means that users must be active for this number of days before they
# can be considered active and guards against the case where lots of users
# sign up in a short space of time never to return after their initial
# session.
#
# 'mau_limit_alerting' is a means of limiting client side alerting
# should the mau limit be reached. This is useful for small instances
# where the admin has 5 mau seats (say) for 5 specific people and no
# interest increasing the mau limit further. Defaults to True, which
# means that alerting is enabled
#
#limit_usage_by_mau: false
#max_mau_value: 50
#mau_trial_days: 2
#mau_limit_alerting: false

# If enabled, the metrics for the number of monthly active users will
# be populated, however no one will be limited. If limit_usage_by_mau
# is true, this is implied to be true.
#
#mau_stats_only: false

# Sometimes the server admin will want to ensure certain accounts are
# never blocked by mau checking. These accounts are specified here.
#
#mau_limit_reserved_threepids:
#  - medium: 'email'
#    address: 'reserved_user@example.com'

# Used by phonehome stats to group together related servers.
#server_context: context

# Resource-constrained homeserver settings
#
# When this is enabled, the room "complexity" will be checked before a user
# joins a new remote room. If it is above the complexity limit, the server will
# disallow joining, or will instantly leave.
#
# Room complexity is an arbitrary measure based on factors such as the number of
# users in the room.
#
limit_remote_rooms:
  # Uncomment to enable room complexity checking.
  #
  #enabled: true

  # the limit above which rooms cannot be joined. The default is 1.0.
  #
  #complexity: 0.5

  # override the error which is returned when the room is too complex.
  #
  #complexity_error: "This room is too complex."

  # allow server admins to join complex rooms. Default is false.
  #
  #admins_can_join: true

# Whether to require a user to be in the room to add an alias to it.
# Defaults to 'true'.
#
#require_membership_for_aliases: false

# Whether to allow per-room membership profiles through the send of membership
# events with profile information that differ from the target's global profile.
# Defaults to 'true'.
#
#allow_per_room_profiles: false

# How long to keep redacted events in unredacted form in the database. After
# this period redacted events get replaced with their redacted form in the DB.
#
# Defaults to `7d`. Set to `null` to disable.
#
#redaction_retention_period: 28d

# How long to track users' last seen time and IPs in the database.
#
# Defaults to `28d`. Set to `null` to disable clearing out of old rows.
#
#user_ips_max_age: 14d

# Message retention policy at the server level.
#
# Room admins and mods can define a retention period for their rooms using the
# 'm.room.retention' state event, and server admins can cap this period by setting
# the 'allowed_lifetime_min' and 'allowed_lifetime_max' config options.
#
# If this feature is enabled, Synapse will regularly look for and purge events
# which are older than the room's maximum retention period. Synapse will also
# filter events received over federation so that events that should have been
# purged are ignored and not stored again.
#
retention:
  # The message retention policies feature is disabled by default. Uncomment the
  # following line to enable it.
  #
  #enabled: true

  # Default retention policy. If set, Synapse will apply it to rooms that lack the
  # 'm.room.retention' state event. Currently, the value of 'min_lifetime' doesn't
  # matter much because Synapse doesn't take it into account yet.
  #
  #default_policy:
  #  min_lifetime: 1d
  #  max_lifetime: 1y

  # Retention policy limits. If set, and the state of a room contains a
  # 'm.room.retention' event in its state which contains a 'min_lifetime' or a
  # 'max_lifetime' that's out of these bounds, Synapse will cap the room's policy
  # to these limits when running purge jobs.
  #
  #allowed_lifetime_min: 1d
  #allowed_lifetime_max: 1y

  # Server admins can define the settings of the background jobs purging the
  # events which lifetime has expired under the 'purge_jobs' section.
  #
  # If no configuration is provided, a single job will be set up to delete expired
  # events in every room daily.
  #
  # Each job's configuration defines which range of message lifetimes the job
  # takes care of. For example, if 'shortest_max_lifetime' is '2d' and
  # 'longest_max_lifetime' is '3d', the job will handle purging expired events in
  # rooms whose state defines a 'max_lifetime' that's both higher than 2 days, and
  # lower than or equal to 3 days. Both the minimum and the maximum value of a
  # range are optional, e.g. a job with no 'shortest_max_lifetime' and a
  # 'longest_max_lifetime' of '3d' will handle every room with a retention policy
  # which 'max_lifetime' is lower than or equal to three days.
  #
  # The rationale for this per-job configuration is that some rooms might have a
  # retention policy with a low 'max_lifetime', where history needs to be purged
  # of outdated messages on a more frequent basis than for the rest of the rooms
  # (e.g. every 12h), but not want that purge to be performed by a job that's
  # iterating over every room it knows, which could be heavy on the server.
  #
  # If any purge job is configured, it is strongly recommended to have at least
  # a single job with neither 'shortest_max_lifetime' nor 'longest_max_lifetime'
  # set, or one job without 'shortest_max_lifetime' and one job without
  # 'longest_max_lifetime' set. Otherwise some rooms might be ignored, even if
  # 'allowed_lifetime_min' and 'allowed_lifetime_max' are set, because capping a
  # room's policy to these values is done after the policies are retrieved from
  # Synapse's database (which is done using the range specified in a purge job's
  # configuration).
  #
  #purge_jobs:
  #  - longest_max_lifetime: 3d
  #    interval: 12h
  #  - shortest_max_lifetime: 3d
  #    interval: 1d

# Inhibits the /requestToken endpoints from returning an error that might leak
# information about whether an e-mail address is in use or not on this
# homeserver.
# Note that for some endpoints the error situation is the e-mail already being
# used, and for others the error is entering the e-mail being unused.
# If this option is enabled, instead of returning an error, these endpoints will
# act as if no error happened and return a fake session ID ('sid') to clients.
#
#request_token_inhibit_3pid_errors: true

# A list of domains that the domain portion of 'next_link' parameters
# must match.
#
# This parameter is optionally provided by clients while requesting
# validation of an email or phone number, and maps to a link that
# users will be automatically redirected to after validation
# succeeds. Clients can make use this parameter to aid the validation
# process.
#
# The whitelist is applied whether the homeserver or an
# identity server is handling validation.
#
# The default value is no whitelist functionality; all domains are
# allowed. Setting this value to an empty list will instead disallow
# all domains.
#
#next_link_domain_whitelist: ["matrix.org"]

# Templates to use when generating email or HTML page contents.
#
templates:
  # Directory in which Synapse will try to find template files to use to generate
  # email or HTML page contents.
  # If not set, or a file is not found within the template directory, a default
  # template from within the Synapse package will be used.
  #
  # See https://matrix-org.github.io/synapse/latest/templates.html for more
  # information about using custom templates.
  #
  #custom_template_directory: /path/to/custom/templates/


## TLS ##

# PEM-encoded X509 certificate for TLS.
# This certificate, as of Synapse 1.0, will need to be a valid and verifiable
# certificate, signed by a recognised Certificate Authority.
#
# Be sure to use a `.pem` file that includes the full certificate chain including
# any intermediate certificates (for instance, if using certbot, use
# `fullchain.pem` as your certificate, not `cert.pem`).
#
#tls_certificate_path: "/data/robin.zenq.me.tls.crt"

# PEM-encoded private key for TLS
#
#tls_private_key_path: "/data/robin.zenq.me.tls.key"

# Whether to verify TLS server certificates for outbound federation requests.
#
# Defaults to `true`. To disable certificate verification, uncomment the
# following line.
#
#federation_verify_certificates: false

# The minimum TLS version that will be used for outbound federation requests.
#
# Defaults to `1`. Configurable to `1`, `1.1`, `1.2`, or `1.3`. Note
# that setting this value higher than `1.2` will prevent federation to most
# of the public Matrix network: only configure it to `1.3` if you have an
# entirely private federation setup and you can ensure TLS 1.3 support.
#
#federation_client_minimum_tls_version: 1.2

# Skip federation certificate verification on the following whitelist
# of domains.
#
# This setting should only be used in very specific cases, such as
# federation over Tor hidden services and similar. For private networks
# of homeservers, you likely want to use a private CA instead.
#
# Only effective if federation_verify_certicates is `true`.
#
#federation_certificate_verification_whitelist:
#  - lon.example.com
#  - *.domain.com
#  - *.onion

# List of custom certificate authorities for federation traffic.
#
# This setting should only normally be used within a private network of
# homeservers.
#
# Note that this list will replace those that are provided by your
# operating environment. Certificates must be in PEM format.
#
#federation_custom_ca_list:
#  - myCA1.pem
#  - myCA2.pem
#  - myCA3.pem


## Federation ##

# Restrict federation to the following whitelist of domains.
# N.B. we recommend also firewalling your federation listener to limit
# inbound federation traffic as early as possible, rather than relying
# purely on this application-layer restriction.  If not specified, the
# default is to whitelist everything.
#
#federation_domain_whitelist:
#  - lon.example.com
#  - nyc.example.com
#  - syd.example.com

# Report prometheus metrics on the age of PDUs being sent to and received from
# the following domains. This can be used to give an idea of "delay" on inbound
# and outbound federation, though be aware that any delay can be due to problems
# at either end or with the intermediate network.
#
# By default, no domains are monitored in this way.
#
#federation_metrics_domains:
#  - matrix.org
#  - example.com

# Uncomment to disable profile lookup over federation. By default, the
# Federation API allows other homeservers to obtain profile data of any user
# on this homeserver. Defaults to 'true'.
#
#allow_profile_lookup_over_federation: false

# Uncomment to disable device display name lookup over federation. By default, the
# Federation API allows other homeservers to obtain device display names of any user
# on this homeserver. Defaults to 'true'.
#
#allow_device_name_lookup_over_federation: false


## Caching ##

# Caching can be configured through the following options.
#
# A cache 'factor' is a multiplier that can be applied to each of
# Synapse's caches in order to increase or decrease the maximum
# number of entries that can be stored.

# The number of events to cache in memory. Not affected by
# caches.global_factor.
#
#event_cache_size: 10K

caches:
  # Controls the global cache factor, which is the default cache factor
  # for all caches if a specific factor for that cache is not otherwise
  # set.
  #
  # This can also be set by the "SYNAPSE_CACHE_FACTOR" environment
  # variable. Setting by environment variable takes priority over
  # setting through the config file.
  #
  # Defaults to 0.5, which will half the size of all caches.
  #
  #global_factor: 1.0

  # A dictionary of cache name to cache factor for that individual
  # cache. Overrides the global cache factor for a given cache.
  #
  # These can also be set through environment variables comprised
  # of "SYNAPSE_CACHE_FACTOR_" + the name of the cache in capital
  # letters and underscores. Setting by environment variable
  # takes priority over setting through the config file.
  # Ex. SYNAPSE_CACHE_FACTOR_GET_USERS_WHO_SHARE_ROOM_WITH_USER=2.0
  #
  # Some caches have '*' and other characters that are not
  # alphanumeric or underscores. These caches can be named with or
  # without the special characters stripped. For example, to specify
  # the cache factor for `*stateGroupCache*` via an environment
  # variable would be `SYNAPSE_CACHE_FACTOR_STATEGROUPCACHE=2.0`.
  #
  per_cache_factors:
    #get_users_who_share_room_with_user: 2.0

  # Controls how long an entry can be in a cache without having been
  # accessed before being evicted. Defaults to None, which means
  # entries are never evicted based on time.
  #
  #expiry_time: 30m

  # Controls how long the results of a /sync request are cached for after
  # a successful response is returned. A higher duration can help clients with
  # intermittent connections, at the cost of higher memory usage.
  #
  # By default, this is zero, which means that sync responses are not cached
  # at all.
  #
  #sync_response_cache_duration: 2m


## Database ##

# The 'database' setting defines the database that synapse uses to store all of
# its data.
#
# 'name' gives the database engine to use: either 'sqlite3' (for SQLite) or
# 'psycopg2' (for PostgreSQL).
#
# 'txn_limit' gives the maximum number of transactions to run per connection
# before reconnecting. Defaults to 0, which means no limit.
#
# 'args' gives options which are passed through to the database engine,
# except for options starting 'cp_', which are used to configure the Twisted
# connection pool. For a reference to valid arguments, see:
#   * for sqlite: https://docs.python.org/3/library/sqlite3.html#sqlite3.connect
#   * for postgres: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PARAMKEYWORDS
#   * for the connection pool: https://twistedmatrix.com/documents/current/api/twisted.enterprise.adbapi.ConnectionPool.html#__init__
#
#
# Example SQLite configuration:
#
#database:
#  name: sqlite3
#  args:
#    database: /path/to/homeserver.db
#
#
# Example Postgres configuration:
#
database:
  name: psycopg2
  txn_limit: 10000
  args:
    user: robin
    password: {{with secret "database/data/robin"}}{{.Data.data.password}}{{end}}
    database: robin
    host: localhost
    port: 5432
    cp_min: 5
    cp_max: 10
#
# For more information on using Synapse with Postgres,
# see https://matrix-org.github.io/synapse/latest/postgres.html.
#
#database:
#  name: sqlite3
#  args:
#    database: /data/homeserver.db


## Logging ##

# A yaml python logging config file as described by
# https://docs.python.org/3.7/library/logging.config.html#configuration-dictionary-schema
#
log_config: "/data/robin.zenq.me.log.config"


## Ratelimiting ##

# Ratelimiting settings for client actions (registration, login, messaging).
#
# Each ratelimiting configuration is made of two parameters:
#   - per_second: number of requests a client can send per second.
#   - burst_count: number of requests a client can send before being throttled.
#
# Synapse currently uses the following configurations:
#   - one for messages that ratelimits sending based on the account the client
#     is using
#   - one for registration that ratelimits registration requests based on the
#     client's IP address.
#   - one for checking the validity of registration tokens that ratelimits
#     requests based on the client's IP address.
#   - one for login that ratelimits login requests based on the client's IP
#     address.
#   - one for login that ratelimits login requests based on the account the
#     client is attempting to log into.
#   - one for login that ratelimits login requests based on the account the
#     client is attempting to log into, based on the amount of failed login
#     attempts for this account.
#   - one for ratelimiting redactions by room admins. If this is not explicitly
#     set then it uses the same ratelimiting as per rc_message. This is useful
#     to allow room admins to deal with abuse quickly.
#   - two for ratelimiting number of rooms a user can join, "local" for when
#     users are joining rooms the server is already in (this is cheap) vs
#     "remote" for when users are trying to join rooms not on the server (which
#     can be more expensive)
#   - one for ratelimiting how often a user or IP can attempt to validate a 3PID.
#   - two for ratelimiting how often invites can be sent in a room or to a
#     specific user.
#
# The defaults are as shown below.
#
#rc_message:
#  per_second: 0.2
#  burst_count: 10
#
#rc_registration:
#  per_second: 0.17
#  burst_count: 3
#
#rc_registration_token_validity:
#  per_second: 0.1
#  burst_count: 5
#
#rc_login:
#  address:
#    per_second: 0.17
#    burst_count: 3
#  account:
#    per_second: 0.17
#    burst_count: 3
#  failed_attempts:
#    per_second: 0.17
#    burst_count: 3
#
#rc_admin_redaction:
#  per_second: 1
#  burst_count: 50
#
#rc_joins:
#  local:
#    per_second: 0.1
#    burst_count: 10
#  remote:
#    per_second: 0.01
#    burst_count: 10
#
#rc_3pid_validation:
#  per_second: 0.003
#  burst_count: 5
#
#rc_invites:
#  per_room:
#    per_second: 0.3
#    burst_count: 10
#  per_user:
#    per_second: 0.003
#    burst_count: 5

# Ratelimiting settings for incoming federation
#
# The rc_federation configuration is made up of the following settings:
#   - window_size: window size in milliseconds
#   - sleep_limit: number of federation requests from a single server in
#     a window before the server will delay processing the request.
#   - sleep_delay: duration in milliseconds to delay processing events
#     from remote servers by if they go over the sleep limit.
#   - reject_limit: maximum number of concurrent federation requests
#     allowed from a single server
#   - concurrent: number of federation requests to concurrently process
#     from a single server
#
# The defaults are as shown below.
#
#rc_federation:
#  window_size: 1000
#  sleep_limit: 10
#  sleep_delay: 500
#  reject_limit: 50
#  concurrent: 3

# Target outgoing federation transaction frequency for sending read-receipts,
# per-room.
#
# If we end up trying to send out more read-receipts, they will get buffered up
# into fewer transactions.
#
#federation_rr_transactions_per_room_per_second: 50



## Media Store ##

# Enable the media store service in the Synapse master. Uncomment the
# following if you are using a separate media store worker.
#
#enable_media_repo: false

# Directory where uploaded images and attachments are stored.
#
media_store_path: "/data/media_store"

# Media storage providers allow media to be stored in different
# locations.
#
#media_storage_providers:
#  - module: file_system
#    # Whether to store newly uploaded local files
#    store_local: false
#    # Whether to store newly downloaded remote files
#    store_remote: false
#    # Whether to wait for successful storage for local uploads
#    store_synchronous: false
#    config:
#       directory: /mnt/some/other/directory

# The largest allowed upload size in bytes
#
# If you are using a reverse proxy you may also need to set this value in
# your reverse proxy's config. Notably Nginx has a small max body size by default.
# See https://matrix-org.github.io/synapse/latest/reverse_proxy.html.
#
#max_upload_size: 50M

# Maximum number of pixels that will be thumbnailed
#
#max_image_pixels: 32M

# Whether to generate new thumbnails on the fly to precisely match
# the resolution requested by the client. If true then whenever
# a new resolution is requested by the client the server will
# generate a new thumbnail. If false the server will pick a thumbnail
# from a precalculated list.
#
#dynamic_thumbnails: false

# List of thumbnails to precalculate when an image is uploaded.
#
#thumbnail_sizes:
#  - width: 32
#    height: 32
#    method: crop
#  - width: 96
#    height: 96
#    method: crop
#  - width: 320
#    height: 240
#    method: scale
#  - width: 640
#    height: 480
#    method: scale
#  - width: 800
#    height: 600
#    method: scale

# Is the preview URL API enabled?
#
# 'false' by default: uncomment the following to enable it (and specify a
# url_preview_ip_range_blacklist blacklist).
#
#url_preview_enabled: true

# List of IP address CIDR ranges that the URL preview spider is denied
# from accessing.  There are no defaults: you must explicitly
# specify a list for URL previewing to work.  You should specify any
# internal services in your network that you do not want synapse to try
# to connect to, otherwise anyone in any Matrix room could cause your
# synapse to issue arbitrary GET requests to your internal services,
# causing serious security issues.
#
# (0.0.0.0 and :: are always blacklisted, whether or not they are explicitly
# listed here, since they correspond to unroutable addresses.)
#
# This must be specified if url_preview_enabled is set. It is recommended that
# you uncomment the following list as a starting point.
#
# Note: The value is ignored when an HTTP proxy is in use
#
#url_preview_ip_range_blacklist:
#  - '127.0.0.0/8'
#  - '10.0.0.0/8'
#  - '172.16.0.0/12'
#  - '192.168.0.0/16'
#  - '100.64.0.0/10'
#  - '192.0.0.0/24'
#  - '169.254.0.0/16'
#  - '192.88.99.0/24'
#  - '198.18.0.0/15'
#  - '192.0.2.0/24'
#  - '198.51.100.0/24'
#  - '203.0.113.0/24'
#  - '224.0.0.0/4'
#  - '::1/128'
#  - 'fe80::/10'
#  - 'fc00::/7'
#  - '2001:db8::/32'
#  - 'ff00::/8'
#  - 'fec0::/10'

# List of IP address CIDR ranges that the URL preview spider is allowed
# to access even if they are specified in url_preview_ip_range_blacklist.
# This is useful for specifying exceptions to wide-ranging blacklisted
# target IP ranges - e.g. for enabling URL previews for a specific private
# website only visible in your network.
#
#url_preview_ip_range_whitelist:
#   - '192.168.1.1'

# Optional list of URL matches that the URL preview spider is
# denied from accessing.  You should use url_preview_ip_range_blacklist
# in preference to this, otherwise someone could define a public DNS
# entry that points to a private IP address and circumvent the blacklist.
# This is more useful if you know there is an entire shape of URL that
# you know that will never want synapse to try to spider.
#
# Each list entry is a dictionary of url component attributes as returned
# by urlparse.urlsplit as applied to the absolute form of the URL.  See
# https://docs.python.org/2/library/urlparse.html#urlparse.urlsplit
# The values of the dictionary are treated as an filename match pattern
# applied to that component of URLs, unless they start with a ^ in which
# case they are treated as a regular expression match.  If all the
# specified component matches for a given list item succeed, the URL is
# blacklisted.
#
#url_preview_url_blacklist:
#  # blacklist any URL with a username in its URI
#  - username: '*'
#
#  # blacklist all *.google.com URLs
#  - netloc: 'google.com'
#  - netloc: '*.google.com'
#
#  # blacklist all plain HTTP URLs
#  - scheme: 'http'
#
#  # blacklist http(s)://www.acme.com/foo
#  - netloc: 'www.acme.com'
#    path: '/foo'
#
#  # blacklist any URL with a literal IPv4 address
#  - netloc: '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'

# The largest allowed URL preview spidering size in bytes
#
#max_spider_size: 10M

# A list of values for the Accept-Language HTTP header used when
# downloading webpages during URL preview generation. This allows
# Synapse to specify the preferred languages that URL previews should
# be in when communicating with remote servers.
#
# Each value is a IETF language tag; a 2-3 letter identifier for a
# language, optionally followed by subtags separated by '-', specifying
# a country or region variant.
#
# Multiple values can be provided, and a weight can be added to each by
# using quality value syntax (;q=). '*' translates to any language.
#
# Defaults to "en".
#
# Example:
#
# url_preview_accept_language:
#   - en-UK
#   - en-US;q=0.9
#   - fr;q=0.8
#   - *;q=0.7
#
url_preview_accept_language:
#   - en


# oEmbed allows for easier embedding content from a website. It can be
# used for generating URLs previews of services which support it.
#
oembed:
  # A default list of oEmbed providers is included with Synapse.
  #
  # Uncomment the following to disable using these default oEmbed URLs.
  # Defaults to 'false'.
  #
  #disable_default_providers: true

  # Additional files with oEmbed configuration (each should be in the
  # form of providers.json).
  #
  # By default, this list is empty (so only the default providers.json
  # is used).
  #
  #additional_providers:
  #  - oembed/my_providers.json


## Captcha ##
# See docs/CAPTCHA_SETUP.md for full details of configuring this.

# This homeserver's ReCAPTCHA public key. Must be specified if
# enable_registration_captcha is enabled.
#
#recaptcha_public_key: "YOUR_PUBLIC_KEY"

# This homeserver's ReCAPTCHA private key. Must be specified if
# enable_registration_captcha is enabled.
#
#recaptcha_private_key: "YOUR_PRIVATE_KEY"

# Uncomment to enable ReCaptcha checks when registering, preventing signup
# unless a captcha is answered. Requires a valid ReCaptcha
# public/private key. Defaults to 'false'.
#
#enable_registration_captcha: true

# The API endpoint to use for verifying m.login.recaptcha responses.
# Defaults to "https://www.recaptcha.net/recaptcha/api/siteverify".
#
#recaptcha_siteverify_api: "https://my.recaptcha.site"


## TURN ##

# The public URIs of the TURN server to give to clients
#
#turn_uris: []

# The shared secret used to compute passwords for the TURN server
#
#turn_shared_secret: "YOUR_SHARED_SECRET"

# The Username and password if the TURN server needs them and
# does not use a token
#
#turn_username: "TURNSERVER_USERNAME"
#turn_password: "TURNSERVER_PASSWORD"

# How long generated TURN credentials last
#
#turn_user_lifetime: 1h

# Whether guests should be allowed to use the TURN server.
# This defaults to True, otherwise VoIP will be unreliable for guests.
# However, it does introduce a slight security risk as it allows users to
# connect to arbitrary endpoints without having first signed up for a
# valid account (e.g. by passing a CAPTCHA).
#
#turn_allow_guests: true


## Registration ##
#
# Registration can be rate-limited using the parameters in the "Ratelimiting"
# section of this file.

# Enable registration for new users.
#
#enable_registration: false

# Time that a user's session remains valid for, after they log in.
#
# Note that this is not currently compatible with guest logins.
#
# Note also that this is calculated at login time: changes are not applied
# retrospectively to users who have already logged in.
#
# By default, this is infinite.
#
#session_lifetime: 24h

# The user must provide all of the below types of 3PID when registering.
#
#registrations_require_3pid:
#  - email
#  - msisdn

# Explicitly disable asking for MSISDNs from the registration
# flow (overrides registrations_require_3pid if MSISDNs are set as required)
#
#disable_msisdn_registration: true

# Mandate that users are only allowed to associate certain formats of
# 3PIDs with accounts on this server.
#
#allowed_local_3pids:
#  - medium: email
#    pattern: '^[^@]+@matrix\.org$'
#  - medium: email
#    pattern: '^[^@]+@vector\.im$'
#  - medium: msisdn
#    pattern: '\+44'

# Enable 3PIDs lookup requests to identity servers from this server.
#
#enable_3pid_lookup: true

# Require users to submit a token during registration.
# Tokens can be managed using the admin API:
# https://matrix-org.github.io/synapse/latest/usage/administration/admin_api/registration_tokens.html
# Note that `enable_registration` must be set to `true`.
# Disabling this option will not delete any tokens previously generated.
# Defaults to false. Uncomment the following to require tokens:
#
#registration_requires_token: true

# If set, allows registration of standard or admin accounts by anyone who
# has the shared secret, even if registration is otherwise disabled.
#
registration_shared_secret: "{{with secret "home/data/robin"}}{{.Data.data.share_secret}}{{end}}"

# Set the number of bcrypt rounds used to generate password hash.
# Larger numbers increase the work factor needed to generate the hash.
# The default number is 12 (which equates to 2^12 rounds).
# N.B. that increasing this will exponentially increase the time required
# to register or login - e.g. 24 => 2^24 rounds which will take >20 mins.
#
#bcrypt_rounds: 12

# Allows users to register as guests without a password/email/etc, and
# participate in rooms hosted on this server which have been made
# accessible to anonymous users.
#
#allow_guest_access: false

# The identity server which we suggest that clients should use when users log
# in on this server.
#
# (By default, no suggestion is made, so it is left up to the client.
# This setting is ignored unless public_baseurl is also set.)
#
#default_identity_server: https://matrix.org

# Handle threepid (email/phone etc) registration and password resets through a set of
# *trusted* identity servers. Note that this allows the configured identity server to
# reset passwords for accounts!
#
# Be aware that if `email` is not set, and SMTP options have not been
# configured in the email config block, registration and user password resets via
# email will be globally disabled.
#
# Additionally, if `msisdn` is not set, registration and password resets via msisdn
# will be disabled regardless, and users will not be able to associate an msisdn
# identifier to their account. This is due to Synapse currently not supporting
# any method of sending SMS messages on its own.
#
# To enable using an identity server for operations regarding a particular third-party
# identifier type, set the value to the URL of that identity server as shown in the
# examples below.
#
# Servers handling the these requests must answer the `/requestToken` endpoints defined
# by the Matrix Identity Service API specification:
# https://matrix.org/docs/spec/identity_service/latest
#
# If a delegate is specified, the config option public_baseurl must also be filled out.
#
account_threepid_delegates:
    #email: https://example.com     # Delegate email sending to example.com
    #msisdn: http://localhost:8090  # Delegate SMS sending to this local process

# Whether users are allowed to change their displayname after it has
# been initially set. Useful when provisioning users based on the
# contents of a third-party directory.
#
# Does not apply to server administrators. Defaults to 'true'
#
#enable_set_displayname: false

# Whether users are allowed to change their avatar after it has been
# initially set. Useful when provisioning users based on the contents
# of a third-party directory.
#
# Does not apply to server administrators. Defaults to 'true'
#
#enable_set_avatar_url: false

# Whether users can change the 3PIDs associated with their accounts
# (email address and msisdn).
#
# Defaults to 'true'
#
#enable_3pid_changes: false

# Users who register on this homeserver will automatically be joined
# to these rooms.
#
# By default, any room aliases included in this list will be created
# as a publicly joinable room when the first user registers for the
# homeserver. This behaviour can be customised with the settings below.
# If the room already exists, make certain it is a publicly joinable
# room. The join rule of the room must be set to 'public'.
#
#auto_join_rooms:
#  - "#example:example.com"

# Where auto_join_rooms are specified, setting this flag ensures that the
# the rooms exist by creating them when the first user on the
# homeserver registers.
#
# By default the auto-created rooms are publicly joinable from any federated
# server. Use the autocreate_auto_join_rooms_federated and
# autocreate_auto_join_room_preset settings below to customise this behaviour.
#
# Setting to false means that if the rooms are not manually created,
# users cannot be auto-joined since they do not exist.
#
# Defaults to true. Uncomment the following line to disable automatically
# creating auto-join rooms.
#
#autocreate_auto_join_rooms: false

# Whether the auto_join_rooms that are auto-created are available via
# federation. Only has an effect if autocreate_auto_join_rooms is true.
#
# Note that whether a room is federated cannot be modified after
# creation.
#
# Defaults to true: the room will be joinable from other servers.
# Uncomment the following to prevent users from other homeservers from
# joining these rooms.
#
#autocreate_auto_join_rooms_federated: false

# The room preset to use when auto-creating one of auto_join_rooms. Only has an
# effect if autocreate_auto_join_rooms is true.
#
# This can be one of "public_chat", "private_chat", or "trusted_private_chat".
# If a value of "private_chat" or "trusted_private_chat" is used then
# auto_join_mxid_localpart must also be configured.
#
# Defaults to "public_chat", meaning that the room is joinable by anyone, including
# federated servers if autocreate_auto_join_rooms_federated is true (the default).
# Uncomment the following to require an invitation to join these rooms.
#
#autocreate_auto_join_room_preset: private_chat

# The local part of the user id which is used to create auto_join_rooms if
# autocreate_auto_join_rooms is true. If this is not provided then the
# initial user account that registers will be used to create the rooms.
#
# The user id is also used to invite new users to any auto-join rooms which
# are set to invite-only.
#
# It *must* be configured if autocreate_auto_join_room_preset is set to
# "private_chat" or "trusted_private_chat".
#
# Note that this must be specified in order for new users to be correctly
# invited to any auto-join rooms which have been set to invite-only (either
# at the time of creation or subsequently).
#
# Note that, if the room already exists, this user must be joined and
# have the appropriate permissions to invite new members.
#
#auto_join_mxid_localpart: system

# When auto_join_rooms is specified, setting this flag to false prevents
# guest accounts from being automatically joined to the rooms.
#
# Defaults to true.
#
#auto_join_rooms_for_guests: false


## Metrics ###

# Enable collection and rendering of performance metrics
#
#enable_metrics: false

# Enable sentry integration
# NOTE: While attempts are made to ensure that the logs don't contain
# any sensitive information, this cannot be guaranteed. By enabling
# this option the sentry server may therefore receive sensitive
# information, and it in turn may then diseminate sensitive information
# through insecure notification channels if so configured.
#
#sentry:
#    dsn: "..."

# Flags to enable Prometheus metrics which are not suitable to be
# enabled by default, either for performance reasons or limited use.
#
metrics_flags:
    # Publish synapse_federation_known_servers, a gauge of the number of
    # servers this homeserver knows about, including itself. May cause
    # performance problems on large homeservers.
    #
    #known_servers: true

# Whether or not to report anonymized homeserver usage statistics.
#
report_stats: false

# The endpoint to report the anonymized homeserver usage statistics to.
# Defaults to https://matrix.org/report-usage-stats/push
#
#report_stats_endpoint: https://example.com/report-usage-stats/push


## API Configuration ##

# Controls for the state that is shared with users who receive an invite
# to a room
#
room_prejoin_state:
   # By default, the following state event types are shared with users who
   # receive invites to the room:
   #
   # - m.room.join_rules
   # - m.room.canonical_alias
   # - m.room.avatar
   # - m.room.encryption
   # - m.room.name
   # - m.room.create
   #
   # Uncomment the following to disable these defaults (so that only the event
   # types listed in 'additional_event_types' are shared). Defaults to 'false'.
   #
   #disable_default_event_types: true

   # Additional state event types to share with users when they are invited
   # to a room.
   #
   # By default, this list is empty (so only the default event types are shared).
   #
   #additional_event_types:
   #  - org.example.custom.event.type


# A list of application service config files to use
#
#app_service_config_files:
#  - app_service_1.yaml
#  - app_service_2.yaml

# Uncomment to enable tracking of application service IP addresses. Implicitly
# enables MAU tracking for application service users.
#
#track_appservice_user_ips: true


# a secret which is used to sign access tokens. If none is specified,
# the registration_shared_secret is used, if one is given; otherwise,
# a secret key is derived from the signing key.
#
macaroon_secret_key: "{{with secret "home/data/robin"}}{{.Data.data.macaroon_secret}}{{end}}"

# a secret which is used to calculate HMACs for form values, to stop
# falsification of values. Must be specified for the User Consent
# forms to work.
#
form_secret: "{{with secret "home/data/robin"}}{{.Data.data.form_secret}}{{end}}"

## Signing Keys ##

# Path to the signing key to sign messages with
#
signing_key_path: "/data/robin.zenq.me.signing.key"

# The keys that the server used to sign messages with but won't use
# to sign new messages.
#
old_signing_keys:
  # For each key, `key` should be the base64-encoded public key, and
  # `expired_ts`should be the time (in milliseconds since the unix epoch) that
  # it was last used.
  #
  # It is possible to build an entry from an old signing.key file using the
  # `export_signing_key` script which is provided with synapse.
  #
  # For example:
  #
  #"ed25519:id": { key: "base64string", expired_ts: 123456789123 }

# How long key response published by this server is valid for.
# Used to set the valid_until_ts in /key/v2 APIs.
# Determines how quickly servers will query to check which keys
# are still valid.
#
#key_refresh_interval: 1d

# The trusted servers to download signing keys from.
#
# When we need to fetch a signing key, each server is tried in parallel.
#
# Normally, the connection to the key server is validated via TLS certificates.
# Additional security can be provided by configuring a `verify key`, which
# will make synapse check that the response is signed by that key.
#
# This setting supercedes an older setting named `perspectives`. The old format
# is still supported for backwards-compatibility, but it is deprecated.
#
# 'trusted_key_servers' defaults to matrix.org, but using it will generate a
# warning on start-up. To suppress this warning, set
# 'suppress_key_server_warning' to true.
#
# Options for each entry in the list include:
#
#    server_name: the name of the server. required.
#
#    verify_keys: an optional map from key id to base64-encoded public key.
#       If specified, we will check that the response is signed by at least
#       one of the given keys.
#
#    accept_keys_insecurely: a boolean. Normally, if `verify_keys` is unset,
#       and federation_verify_certificates is not `true`, synapse will refuse
#       to start, because this would allow anyone who can spoof DNS responses
#       to masquerade as the trusted key server. If you know what you are doing
#       and are sure that your network environment provides a secure connection
#       to the key server, you can set this to `true` to override this
#       behaviour.
#
# An example configuration might look like:
#
#trusted_key_servers:
#  - server_name: "my_trusted_server.example.com"
#    verify_keys:
#      "ed25519:auto": "abcdefghijklmnopqrstuvwxyzabcdefghijklmopqr"
#  - server_name: "my_other_trusted_server.example.com"
#
trusted_key_servers:
  - server_name: "matrix.org"

# Uncomment the following to disable the warning that is emitted when the
# trusted_key_servers include 'matrix.org'. See above.
#
#suppress_key_server_warning: true

# The signing keys to use when acting as a trusted key server. If not specified
# defaults to the server signing key.
#
# Can contain multiple keys, one per line.
#
#key_server_signing_keys_path: "key_server_signing_keys.key"


## Single sign-on integration ##

# The following settings can be used to make Synapse use a single sign-on
# provider for authentication, instead of its internal password database.
#
# You will probably also want to set the following options to `false` to
# disable the regular login/registration flows:
#   * enable_registration
#   * password_config.enabled
#
# You will also want to investigate the settings under the "sso" configuration
# section below.

# Enable SAML2 for registration and login. Uses pysaml2.
#
# At least one of `sp_config` or `config_path` must be set in this section to
# enable SAML login.
#
# Once SAML support is enabled, a metadata file will be exposed at
# https://<server>:<port>/_synapse/client/saml2/metadata.xml, which you may be able to
# use to configure your SAML IdP with. Alternatively, you can manually configure
# the IdP to use an ACS location of
# https://<server>:<port>/_synapse/client/saml2/authn_response.
#
saml2_config:
  # `sp_config` is the configuration for the pysaml2 Service Provider.
  # See pysaml2 docs for format of config.
  #
  # Default values will be used for the 'entityid' and 'service' settings,
  # so it is not normally necessary to specify them unless you need to
  # override them.
  #
  sp_config:
    # Point this to the IdP's metadata. You must provide either a local
    # file via the `local` attribute or (preferably) a URL via the
    # `remote` attribute.
    #
    #metadata:
    #  local: ["saml2/idp.xml"]
    #  remote:
    #    - url: https://our_idp/metadata.xml

    # Allowed clock difference in seconds between the homeserver and IdP.
    #
    # Uncomment the below to increase the accepted time difference from 0 to 3 seconds.
    #
    #accepted_time_diff: 3

    # By default, the user has to go to our login page first. If you'd like
    # to allow IdP-initiated login, set 'allow_unsolicited: true' in a
    # 'service.sp' section:
    #
    #service:
    #  sp:
    #    allow_unsolicited: true

    # The examples below are just used to generate our metadata xml, and you
    # may well not need them, depending on your setup. Alternatively you
    # may need a whole lot more detail - see the pysaml2 docs!

    #description: ["My awesome SP", "en"]
    #name: ["Test SP", "en"]

    #ui_info:
    #  display_name:
    #    - lang: en
    #      text: "Display Name is the descriptive name of your service."
    #  description:
    #    - lang: en
    #      text: "Description should be a short paragraph explaining the purpose of the service."
    #  information_url:
    #    - lang: en
    #      text: "https://example.com/terms-of-service"
    #  privacy_statement_url:
    #    - lang: en
    #      text: "https://example.com/privacy-policy"
    #  keywords:
    #    - lang: en
    #      text: ["Matrix", "Element"]
    #  logo:
    #    - lang: en
    #      text: "https://example.com/logo.svg"
    #      width: "200"
    #      height: "80"

    #organization:
    #  name: Example com
    #  display_name:
    #    - ["Example co", "en"]
    #  url: "http://example.com"

    #contact_person:
    #  - given_name: Bob
    #    sur_name: "the Sysadmin"
    #    email_address": ["admin@example.com"]
    #    contact_type": technical

  # Instead of putting the config inline as above, you can specify a
  # separate pysaml2 configuration file:
  #
  #config_path: "/data/sp_conf.py"

  # The lifetime of a SAML session. This defines how long a user has to
  # complete the authentication process, if allow_unsolicited is unset.
  # The default is 15 minutes.
  #
  #saml_session_lifetime: 5m

  # An external module can be provided here as a custom solution to
  # mapping attributes returned from a saml provider onto a matrix user.
  #
  user_mapping_provider:
    # The custom module's class. Uncomment to use a custom module.
    #
    #module: mapping_provider.SamlMappingProvider

    # Custom configuration values for the module. Below options are
    # intended for the built-in provider, they should be changed if
    # using a custom module. This section will be passed as a Python
    # dictionary to the module's `parse_config` method.
    #
    config:
      # The SAML attribute (after mapping via the attribute maps) to use
      # to derive the Matrix ID from. 'uid' by default.
      #
      # Note: This used to be configured by the
      # saml2_config.mxid_source_attribute option. If that is still
      # defined, its value will be used instead.
      #
      #mxid_source_attribute: displayName

      # The mapping system to use for mapping the saml attribute onto a
      # matrix ID.
      #
      # Options include:
      #  * 'hexencode' (which maps unpermitted characters to '=xx')
      #  * 'dotreplace' (which replaces unpermitted characters with
      #     '.').
      # The default is 'hexencode'.
      #
      # Note: This used to be configured by the
      # saml2_config.mxid_mapping option. If that is still defined, its
      # value will be used instead.
      #
      #mxid_mapping: dotreplace

  # In previous versions of synapse, the mapping from SAML attribute to
  # MXID was always calculated dynamically rather than stored in a
  # table. For backwards- compatibility, we will look for user_ids
  # matching such a pattern before creating a new account.
  #
  # This setting controls the SAML attribute which will be used for this
  # backwards-compatibility lookup. Typically it should be 'uid', but if
  # the attribute maps are changed, it may be necessary to change it.
  #
  # The default is 'uid'.
  #
  #grandfathered_mxid_source_attribute: upn

  # It is possible to configure Synapse to only allow logins if SAML attributes
  # match particular values. The requirements can be listed under
  # `attribute_requirements` as shown below. All of the listed attributes must
  # match for the login to be permitted.
  #
  #attribute_requirements:
  #  - attribute: userGroup
  #    value: "staff"
  #  - attribute: department
  #    value: "sales"

  # If the metadata XML contains multiple IdP entities then the `idp_entityid`
  # option must be set to the entity to redirect users to.
  #
  # Most deployments only have a single IdP entity and so should omit this
  # option.
  #
  #idp_entityid: 'https://our_idp/entityid'


# List of OpenID Connect (OIDC) / OAuth 2.0 identity providers, for registration
# and login.
#
# Options for each entry include:
#
#   idp_id: a unique identifier for this identity provider. Used internally
#       by Synapse; should be a single word such as 'github'.
#
#       Note that, if this is changed, users authenticating via that provider
#       will no longer be recognised as the same user!
#
#       (Use "oidc" here if you are migrating from an old "oidc_config"
#       configuration.)
#
#   idp_name: A user-facing name for this identity provider, which is used to
#       offer the user a choice of login mechanisms.
#
#   idp_icon: An optional icon for this identity provider, which is presented
#       by clients and Synapse's own IdP picker page. If given, must be an
#       MXC URI of the format mxc://<server-name>/<media-id>. (An easy way to
#       obtain such an MXC URI is to upload an image to an (unencrypted) room
#       and then copy the "url" from the source of the event.)
#
#   idp_brand: An optional brand for this identity provider, allowing clients
#       to style the login flow according to the identity provider in question.
#       See the spec for possible options here.
#
#   discover: set to 'false' to disable the use of the OIDC discovery mechanism
#       to discover endpoints. Defaults to true.
#
#   issuer: Required. The OIDC issuer. Used to validate tokens and (if discovery
#       is enabled) to discover the provider's endpoints.
#
#   client_id: Required. oauth2 client id to use.
#
#   client_secret: oauth2 client secret to use. May be omitted if
#        client_secret_jwt_key is given, or if client_auth_method is 'none'.
#
#   client_secret_jwt_key: Alternative to client_secret: details of a key used
#      to create a JSON Web Token to be used as an OAuth2 client secret. If
#      given, must be a dictionary with the following properties:
#
#          key: a pem-encoded signing key. Must be a suitable key for the
#              algorithm specified. Required unless 'key_file' is given.
#
#          key_file: the path to file containing a pem-encoded signing key file.
#              Required unless 'key' is given.
#
#          jwt_header: a dictionary giving properties to include in the JWT
#              header. Must include the key 'alg', giving the algorithm used to
#              sign the JWT, such as "ES256", using the JWA identifiers in
#              RFC7518.
#
#          jwt_payload: an optional dictionary giving properties to include in
#              the JWT payload. Normally this should include an 'iss' key.
#
#   client_auth_method: auth method to use when exchanging the token. Valid
#       values are 'client_secret_basic' (default), 'client_secret_post' and
#       'none'.
#
#   scopes: list of scopes to request. This should normally include the "openid"
#       scope. Defaults to ["openid"].
#
#   authorization_endpoint: the oauth2 authorization endpoint. Required if
#       provider discovery is disabled.
#
#   token_endpoint: the oauth2 token endpoint. Required if provider discovery is
#       disabled.
#
#   userinfo_endpoint: the OIDC userinfo endpoint. Required if discovery is
#       disabled and the 'openid' scope is not requested.
#
#   jwks_uri: URI where to fetch the JWKS. Required if discovery is disabled and
#       the 'openid' scope is used.
#
#   skip_verification: set to 'true' to skip metadata verification. Use this if
#       you are connecting to a provider that is not OpenID Connect compliant.
#       Defaults to false. Avoid this in production.
#
#   user_profile_method: Whether to fetch the user profile from the userinfo
#       endpoint. Valid values are: 'auto' or 'userinfo_endpoint'.
#
#       Defaults to 'auto', which fetches the userinfo endpoint if 'openid' is
#       included in 'scopes'. Set to 'userinfo_endpoint' to always fetch the
#       userinfo endpoint.
#
#   allow_existing_users: set to 'true' to allow a user logging in via OIDC to
#       match a pre-existing account instead of failing. This could be used if
#       switching from password logins to OIDC. Defaults to false.
#
#   user_mapping_provider: Configuration for how attributes returned from a OIDC
#       provider are mapped onto a matrix user. This setting has the following
#       sub-properties:
#
#       module: The class name of a custom mapping module. Default is
#           'synapse.handlers.oidc.JinjaOidcMappingProvider'.
#           See https://matrix-org.github.io/synapse/latest/sso_mapping_providers.html#openid-mapping-providers
#           for information on implementing a custom mapping provider.
#
#       config: Configuration for the mapping provider module. This section will
#           be passed as a Python dictionary to the user mapping provider
#           module's `parse_config` method.
#
#           For the default provider, the following settings are available:
#
#             subject_claim: name of the claim containing a unique identifier
#                 for the user. Defaults to 'sub', which OpenID Connect
#                 compliant providers should provide.
#
#             localpart_template: Jinja2 template for the localpart of the MXID.
#                 If this is not set, the user will be prompted to choose their
#                 own username (see 'sso_auth_account_details.html' in the 'sso'
#                 section of this file).
#
#             display_name_template: Jinja2 template for the display name to set
#                 on first login. If unset, no displayname will be set.
#
#             email_template: Jinja2 template for the email address of the user.
#                 If unset, no email address will be added to the account.
#
#             extra_attributes: a map of Jinja2 templates for extra attributes
#                 to send back to the client during login.
#                 Note that these are non-standard and clients will ignore them
#                 without modifications.
#
#           When rendering, the Jinja2 templates are given a 'user' variable,
#           which is set to the claims returned by the UserInfo Endpoint and/or
#           in the ID Token.
#
#   It is possible to configure Synapse to only allow logins if certain attributes
#   match particular values in the OIDC userinfo. The requirements can be listed under
#   `attribute_requirements` as shown below. All of the listed attributes must
#   match for the login to be permitted. Additional attributes can be added to
#   userinfo by expanding the `scopes` section of the OIDC config to retrieve
#   additional information from the OIDC provider.
#
#   If the OIDC claim is a list, then the attribute must match any value in the list.
#   Otherwise, it must exactly match the value of the claim. Using the example
#   below, the `family_name` claim MUST be "Stephensson", but the `groups`
#   claim MUST contain "admin".
#
#   attribute_requirements:
#     - attribute: family_name
#       value: "Stephensson"
#     - attribute: groups
#       value: "admin"
#
# See https://matrix-org.github.io/synapse/latest/openid.html
# for information on how to configure these options.
#
# For backwards compatibility, it is also possible to configure a single OIDC
# provider via an 'oidc_config' setting. This is now deprecated and admins are
# advised to migrate to the 'oidc_providers' format. (When doing that migration,
# use 'oidc' for the idp_id to ensure that existing users continue to be
# recognised.)
#
oidc_providers:
  # Generic example
  #
  #- idp_id: my_idp
  #  idp_name: "My OpenID provider"
  #  idp_icon: "mxc://example.com/mediaid"
  #  discover: false
  #  issuer: "https://accounts.example.com/"
  #  client_id: "provided-by-your-issuer"
  #  client_secret: "provided-by-your-issuer"
  #  client_auth_method: client_secret_post
  #  scopes: ["openid", "profile"]
  #  authorization_endpoint: "https://accounts.example.com/oauth2/auth"
  #  token_endpoint: "https://accounts.example.com/oauth2/token"
  #  userinfo_endpoint: "https://accounts.example.com/userinfo"
  #  jwks_uri: "https://accounts.example.com/.well-known/jwks.json"
  #  skip_verification: true
  #  user_mapping_provider:
  #    config:
  #      subject_claim: "id"
  #      localpart_template: ""{{" user.login "}}""
  #      display_name_template: ""{{" user.name "}}""
  #      email_template: ""{{" user.email "}}""
  #  attribute_requirements:
  #    - attribute: userGroup
  #      value: "synapseUsers"


# Enable Central Authentication Service (CAS) for registration and login.
#
cas_config:
  # Uncomment the following to enable authorization against a CAS server.
  # Defaults to false.
  #
  #enabled: true

  # The URL of the CAS authorization endpoint.
  #
  #server_url: "https://cas-server.com"

  # The attribute of the CAS response to use as the display name.
  #
  # If unset, no displayname will be set.
  #
  #displayname_attribute: name

  # It is possible to configure Synapse to only allow logins if CAS attributes
  # match particular values. All of the keys in the mapping below must exist
  # and the values must match the given value. Alternately if the given value
  # is None then any value is allowed (the attribute just must exist).
  # All of the listed attributes must match for the login to be permitted.
  #
  #required_attributes:
  #  userGroup: "staff"
  #  department: None


# Additional settings to use with single-sign on systems such as OpenID Connect,
# SAML2 and CAS.
#
# Server admins can configure custom templates for pages related to SSO. See
# https://matrix-org.github.io/synapse/latest/templates.html for more information.
#
sso:
    # A list of client URLs which are whitelisted so that the user does not
    # have to confirm giving access to their account to the URL. Any client
    # whose URL starts with an entry in the following list will not be subject
    # to an additional confirmation step after the SSO login is completed.
    #
    # WARNING: An entry such as "https://my.client" is insecure, because it
    # will also match "https://my.client.evil.site", exposing your users to
    # phishing attacks from evil.site. To avoid this, include a slash after the
    # hostname: "https://my.client/".
    #
    # If public_baseurl is set, then the login fallback page (used by clients
    # that don't natively support the required login flows) is whitelisted in
    # addition to any URLs in this list.
    #
    # By default, this list is empty.
    #
    #client_whitelist:
    #  - https://riot.im/develop
    #  - https://my.custom.client/

    # Uncomment to keep a user's profile fields in sync with information from
    # the identity provider. Currently only syncing the displayname is
    # supported. Fields are checked on every SSO login, and are updated
    # if necessary.
    #
    # Note that enabling this option will override user profile information,
    # regardless of whether users have opted-out of syncing that
    # information when first signing in. Defaults to false.
    #
    #update_profile_information: true


# JSON web token integration. The following settings can be used to make
# Synapse JSON web tokens for authentication, instead of its internal
# password database.
#
# Each JSON Web Token needs to contain a "sub" (subject) claim, which is
# used as the localpart of the mxid.
#
# Additionally, the expiration time ("exp"), not before time ("nbf"),
# and issued at ("iat") claims are validated if present.
#
# Note that this is a non-standard login type and client support is
# expected to be non-existent.
#
# See https://matrix-org.github.io/synapse/latest/jwt.html.
#
#jwt_config:
    # Uncomment the following to enable authorization using JSON web
    # tokens. Defaults to false.
    #
    #enabled: true

    # This is either the private shared secret or the public key used to
    # decode the contents of the JSON web token.
    #
    # Required if 'enabled' is true.
    #
    #secret: "provided-by-your-issuer"

    # The algorithm used to sign the JSON web token.
    #
    # Supported algorithms are listed at
    # https://pyjwt.readthedocs.io/en/latest/algorithms.html
    #
    # Required if 'enabled' is true.
    #
    #algorithm: "provided-by-your-issuer"

    # The issuer to validate the "iss" claim against.
    #
    # Optional, if provided the "iss" claim will be required and
    # validated for all JSON web tokens.
    #
    #issuer: "provided-by-your-issuer"

    # A list of audiences to validate the "aud" claim against.
    #
    # Optional, if provided the "aud" claim will be required and
    # validated for all JSON web tokens.
    #
    # Note that if the "aud" claim is included in a JSON web token then
    # validation will fail without configuring audiences.
    #
    #audiences:
    #    - "provided-by-your-issuer"


password_config:
   # Uncomment to disable password login
   #
   #enabled: false

   # Uncomment to disable authentication against the local password
   # database. This is ignored if `enabled` is false, and is only useful
   # if you have other password_providers.
   #
   #localdb_enabled: false

   # Uncomment and change to a secret random string for extra security.
   # DO NOT CHANGE THIS AFTER INITIAL SETUP!
   #
   #pepper: "EVEN_MORE_SECRET"

   # Define and enforce a password policy. Each parameter is optional.
   # This is an implementation of MSC2000.
   #
   policy:
      # Whether to enforce the password policy.
      # Defaults to 'false'.
      #
      #enabled: true

      # Minimum accepted length for a password.
      # Defaults to 0.
      #
      #minimum_length: 15

      # Whether a password must contain at least one digit.
      # Defaults to 'false'.
      #
      #require_digit: true

      # Whether a password must contain at least one symbol.
      # A symbol is any character that's not a number or a letter.
      # Defaults to 'false'.
      #
      #require_symbol: true

      # Whether a password must contain at least one lowercase letter.
      # Defaults to 'false'.
      #
      #require_lowercase: true

      # Whether a password must contain at least one uppercase letter.
      # Defaults to 'false'.
      #
      #require_uppercase: true

ui_auth:
    # The amount of time to allow a user-interactive authentication session
    # to be active.
    #
    # This defaults to 0, meaning the user is queried for their credentials
    # before every action, but this can be overridden to allow a single
    # validation to be re-used.  This weakens the protections afforded by
    # the user-interactive authentication process, by allowing for multiple
    # (and potentially different) operations to use the same validation session.
    #
    # This is ignored for potentially "dangerous" operations (including
    # deactivating an account, modifying an account password, and
    # adding a 3PID).
    #
    # Uncomment below to allow for credential validation to last for 15
    # seconds.
    #
    #session_timeout: "15s"


# Configuration for sending emails from Synapse.
#
# Server admins can configure custom templates for email content. See
# https://matrix-org.github.io/synapse/latest/templates.html for more information.
#
email:
  # The hostname of the outgoing SMTP server to use. Defaults to 'localhost'.
  #
  #smtp_host: mail.server

  # The port on the mail server for outgoing SMTP. Defaults to 25.
  #
  #smtp_port: 587

  # Username/password for authentication to the SMTP server. By default, no
  # authentication is attempted.
  #
  #smtp_user: "exampleusername"
  #smtp_pass: "examplepassword"

  # Uncomment the following to require TLS transport security for SMTP.
  # By default, Synapse will connect over plain text, and will then switch to
  # TLS via STARTTLS *if the SMTP server supports it*. If this option is set,
  # Synapse will refuse to connect unless the server supports STARTTLS.
  #
  #require_transport_security: true

  # Uncomment the following to disable TLS for SMTP.
  #
  # By default, if the server supports TLS, it will be used, and the server
  # must present a certificate that is valid for 'smtp_host'. If this option
  # is set to false, TLS will not be used.
  #
  #enable_tls: false

  # notif_from defines the "From" address to use when sending emails.
  # It must be set if email sending is enabled.
  #
  # The placeholder '%(app)s' will be replaced by the application name,
  # which is normally 'app_name' (below), but may be overridden by the
  # Matrix client application.
  #
  # Note that the placeholder must be written '%(app)s', including the
  # trailing 's'.
  #
  #notif_from: "Your Friendly %(app)s homeserver <noreply@example.com>"

  # app_name defines the default value for '%(app)s' in notif_from and email
  # subjects. It defaults to 'Matrix'.
  #
  #app_name: my_branded_matrix_server

  # Uncomment the following to enable sending emails for messages that the user
  # has missed. Disabled by default.
  #
  #enable_notifs: true

  # Uncomment the following to disable automatic subscription to email
  # notifications for new users. Enabled by default.
  #
  #notif_for_new_users: false

  # Custom URL for client links within the email notifications. By default
  # links will be based on "https://matrix.to".
  #
  # (This setting used to be called riot_base_url; the old name is still
  # supported for backwards-compatibility but is now deprecated.)
  #
  #client_base_url: "http://localhost/riot"

  # Configure the time that a validation email will expire after sending.
  # Defaults to 1h.
  #
  #validation_token_lifetime: 15m

  # The web client location to direct users to during an invite. This is passed
  # to the identity server as the org.matrix.web_client_location key. Defaults
  # to unset, giving no guidance to the identity server.
  #
  #invite_client_location: https://app.element.io

  # Subjects to use when sending emails from Synapse.
  #
  # The placeholder '%(app)s' will be replaced with the value of the 'app_name'
  # setting above, or by a value dictated by the Matrix client application.
  #
  # If a subject isn't overridden in this configuration file, the value used as
  # its example will be used.
  #
  #subjects:

    # Subjects for notification emails.
    #
    # On top of the '%(app)s' placeholder, these can use the following
    # placeholders:
    #
    #   * '%(person)s', which will be replaced by the display name of the user(s)
    #      that sent the message(s), e.g. "Alice and Bob".
    #   * '%(room)s', which will be replaced by the name of the room the
    #      message(s) have been sent to, e.g. "My super room".
    #
    # See the example provided for each setting to see which placeholder can be
    # used and how to use them.
    #
    # Subject to use to notify about one message from one or more user(s) in a
    # room which has a name.
    #message_from_person_in_room: "[%(app)s] You have a message on %(app)s from %(person)s in the %(room)s room..."
    #
    # Subject to use to notify about one message from one or more user(s) in a
    # room which doesn't have a name.
    #message_from_person: "[%(app)s] You have a message on %(app)s from %(person)s..."
    #
    # Subject to use to notify about multiple messages from one or more users in
    # a room which doesn't have a name.
    #messages_from_person: "[%(app)s] You have messages on %(app)s from %(person)s..."
    #
    # Subject to use to notify about multiple messages in a room which has a
    # name.
    #messages_in_room: "[%(app)s] You have messages on %(app)s in the %(room)s room..."
    #
    # Subject to use to notify about multiple messages in multiple rooms.
    #messages_in_room_and_others: "[%(app)s] You have messages on %(app)s in the %(room)s room and others..."
    #
    # Subject to use to notify about multiple messages from multiple persons in
    # multiple rooms. This is similar to the setting above except it's used when
    # the room in which the notification was triggered has no name.
    #messages_from_person_and_others: "[%(app)s] You have messages on %(app)s from %(person)s and others..."
    #
    # Subject to use to notify about an invite to a room which has a name.
    #invite_from_person_to_room: "[%(app)s] %(person)s has invited you to join the %(room)s room on %(app)s..."
    #
    # Subject to use to notify about an invite to a room which doesn't have a
    # name.
    #invite_from_person: "[%(app)s] %(person)s has invited you to chat on %(app)s..."

    # Subject for emails related to account administration.
    #
    # On top of the '%(app)s' placeholder, these one can use the
    # '%(server_name)s' placeholder, which will be replaced by the value of the
    # 'server_name' setting in your Synapse configuration.
    #
    # Subject to use when sending a password reset email.
    #password_reset: "[%(server_name)s] Password reset"
    #
    # Subject to use when sending a verification email to assert an address's
    # ownership.
    #email_validation: "[%(server_name)s] Validate your email"


# Password providers allow homeserver administrators to integrate
# their Synapse installation with existing authentication methods
# ex. LDAP, external tokens, etc.
#
# For more information and known implementations, please see
# https://matrix-org.github.io/synapse/latest/password_auth_providers.html
#
# Note: instances wishing to use SAML or CAS authentication should
# instead use the `saml2_config` or `cas_config` options,
# respectively.
#
password_providers:
#    # Example config for an LDAP auth provider
#    - module: "ldap_auth_provider.LdapAuthProvider"
#      config:
#        enabled: true
#        uri: "ldap://ldap.example.com:389"
#        start_tls: true
#        base: "ou=users,dc=example,dc=com"
#        attributes:
#           uid: "cn"
#           mail: "email"
#           name: "givenName"
#        #bind_dn:
#        #bind_password:
#        #filter: "(objectClass=posixAccount)"



## Push ##

push:
  # Clients requesting push notifications can either have the body of
  # the message sent in the notification poke along with other details
  # like the sender, or just the event ID and room ID (`event_id_only`).
  # If clients choose the former, this option controls whether the
  # notification request includes the content of the event (other details
  # like the sender are still included). For `event_id_only` push, it
  # has no effect.
  #
  # For modern android devices the notification content will still appear
  # because it is loaded by the app. iPhone, however will send a
  # notification saying only that a message arrived and who it came from.
  #
  # The default value is "true" to include message details. Uncomment to only
  # include the event ID and room ID in push notification payloads.
  #
  #include_content: false

  # When a push notification is received, an unread count is also sent.
  # This number can either be calculated as the number of unread messages
  # for the user, or the number of *rooms* the user has unread messages in.
  #
  # The default value is "true", meaning push clients will see the number of
  # rooms with unread messages in them. Uncomment to instead send the number
  # of unread messages.
  #
  #group_unread_count_by_room: false


## Rooms ##

# Controls whether locally-created rooms should be end-to-end encrypted by
# default.
#
# Possible options are "all", "invite", and "off". They are defined as:
#
# * "all": any locally-created room
# * "invite": any room created with the "private_chat" or "trusted_private_chat"
#             room creation presets
# * "off": this option will take no effect
#
# The default value is "off".
#
# Note that this option will only affect rooms created after it is set. It
# will also not affect rooms created by other servers.
#
#encryption_enabled_by_default_for_room_type: invite


# Uncomment to allow non-server-admin users to create groups on this server
#
#enable_group_creation: true

# If enabled, non server admins can only create groups with local parts
# starting with this prefix
#
#group_creation_prefix: "unofficial_"



# User Directory configuration
#
user_directory:
    # Defines whether users can search the user directory. If false then
    # empty responses are returned to all queries. Defaults to true.
    #
    # Uncomment to disable the user directory.
    #
    #enabled: false

    # Defines whether to search all users visible to your HS when searching
    # the user directory, rather than limiting to users visible in public
    # rooms. Defaults to false.
    #
    # If you set it true, you'll have to rebuild the user_directory search
    # indexes, see:
    # https://matrix-org.github.io/synapse/latest/user_directory.html
    #
    # Uncomment to return search results containing all known users, even if that
    # user does not share a room with the requester.
    #
    #search_all_users: true

    # Defines whether to prefer local users in search query results.
    # If True, local users are more likely to appear above remote users
    # when searching the user directory. Defaults to false.
    #
    # Uncomment to prefer local over remote users in user directory search
    # results.
    #
    #prefer_local_users: true


# User Consent configuration
#
# for detailed instructions, see
# https://matrix-org.github.io/synapse/latest/consent_tracking.html
#
# Parts of this section are required if enabling the 'consent' resource under
# 'listeners', in particular 'template_dir' and 'version'.
#
# 'template_dir' gives the location of the templates for the HTML forms.
# This directory should contain one subdirectory per language (eg, 'en', 'fr'),
# and each language directory should contain the policy document (named as
# '<version>.html') and a success page (success.html).
#
# 'version' specifies the 'current' version of the policy document. It defines
# the version to be served by the consent resource if there is no 'v'
# parameter.
#
# 'server_notice_content', if enabled, will send a user a "Server Notice"
# asking them to consent to the privacy policy. The 'server_notices' section
# must also be configured for this to work. Notices will *not* be sent to
# guest users unless 'send_server_notice_to_guests' is set to true.
#
# 'block_events_error', if set, will block any attempts to send events
# until the user consents to the privacy policy. The value of the setting is
# used as the text of the error.
#
# 'require_at_registration', if enabled, will add a step to the registration
# process, similar to how captcha works. Users will be required to accept the
# policy before their account is created.
#
# 'policy_name' is the display name of the policy users will see when registering
# for an account. Has no effect unless `require_at_registration` is enabled.
# Defaults to "Privacy Policy".
#
#user_consent:
#  template_dir: res/templates/privacy
#  version: 1.0
#  server_notice_content:
#    msgtype: m.text
#    body: >-
#      To continue using this homeserver you must review and agree to the
#      terms and conditions at %(consent_uri)s
#  send_server_notice_to_guests: true
#  block_events_error: >-
#    To continue using this homeserver you must review and agree to the
#    terms and conditions at %(consent_uri)s
#  require_at_registration: false
#  policy_name: Privacy Policy
#



# Settings for local room and user statistics collection. See
# https://matrix-org.github.io/synapse/latest/room_and_user_statistics.html.
#
stats:
  # Uncomment the following to disable room and user statistics. Note that doing
  # so may cause certain features (such as the room directory) not to work
  # correctly.
  #
  #enabled: false


# Server Notices room configuration
#
# Uncomment this section to enable a room which can be used to send notices
# from the server to users. It is a special room which cannot be left; notices
# come from a special "notices" user id.
#
# If you uncomment this section, you *must* define the system_mxid_localpart
# setting, which defines the id of the user which will be used to send the
# notices.
#
# It's also possible to override the room name, the display name of the
# "notices" user, and the avatar for the user.
#
#server_notices:
#  system_mxid_localpart: notices
#  system_mxid_display_name: "Server Notices"
#  system_mxid_avatar_url: "mxc://server.com/oumMVlgDnLYFaPVkExemNVVZ"
#  room_name: "Server Notices"



# Uncomment to disable searching the public room list. When disabled
# blocks searching local and remote room lists for local and remote
# users by always returning an empty list for all queries.
#
#enable_room_list_search: false

# The `alias_creation` option controls who's allowed to create aliases
# on this server.
#
# The format of this option is a list of rules that contain globs that
# match against user_id, room_id and the new alias (fully qualified with
# server name). The action in the first rule that matches is taken,
# which can currently either be "allow" or "deny".
#
# Missing user_id/room_id/alias fields default to "*".
#
# If no rules match the request is denied. An empty list means no one
# can create aliases.
#
# Options for the rules include:
#
#   user_id: Matches against the creator of the alias
#   alias: Matches against the alias being created
#   room_id: Matches against the room ID the alias is being pointed at
#   action: Whether to "allow" or "deny" the request if the rule matches
#
# The default is:
#
#alias_creation_rules:
#  - user_id: "*"
#    alias: "*"
#    room_id: "*"
#    action: allow

# The `room_list_publication_rules` option controls who can publish and
# which rooms can be published in the public room list.
#
# The format of this option is the same as that for
# `alias_creation_rules`.
#
# If the room has one or more aliases associated with it, only one of
# the aliases needs to match the alias rule. If there are no aliases
# then only rules with `alias: *` match.
#
# If no rules match the request is denied. An empty list means no one
# can publish rooms.
#
# Options for the rules include:
#
#   user_id: Matches against the creator of the alias
#   room_id: Matches against the room ID being published
#   alias: Matches against any current local or canonical aliases
#            associated with the room
#   action: Whether to "allow" or "deny" the request if the rule matches
#
# The default is:
#
#room_list_publication_rules:
#  - user_id: "*"
#    alias: "*"
#    room_id: "*"
#    action: allow


## Opentracing ##

# These settings enable opentracing, which implements distributed tracing.
# This allows you to observe the causal chains of events across servers
# including requests, key lookups etc., across any server running
# synapse or any other other services which supports opentracing
# (specifically those implemented with Jaeger).
#
opentracing:
    # tracing is disabled by default. Uncomment the following line to enable it.
    #
    #enabled: true

    # The list of homeservers we wish to send and receive span contexts and span baggage.
    # See https://matrix-org.github.io/synapse/latest/opentracing.html.
    #
    # This is a list of regexes which are matched against the server_name of the
    # homeserver.
    #
    # By default, it is empty, so no servers are matched.
    #
    #homeserver_whitelist:
    #  - ".*"

    # A list of the matrix IDs of users whose requests will always be traced,
    # even if the tracing system would otherwise drop the traces due to
    # probabilistic sampling.
    #
    # By default, the list is empty.
    #
    #force_tracing_for_users:
    #  - "@user1:server_name"
    #  - "@user2:server_name"

    # Jaeger can be configured to sample traces at different rates.
    # All configuration options provided by Jaeger can be set here.
    # Jaeger's configuration is mostly related to trace sampling which
    # is documented here:
    # https://www.jaegertracing.io/docs/latest/sampling/.
    #
    #jaeger_config:
    #  sampler:
    #    type: const
    #    param: 1
    #  logging:
    #    false


## Workers ##

# Disables sending of outbound federation transactions on the main process.
# Uncomment if using a federation sender worker.
#
#send_federation: false

# It is possible to run multiple federation sender workers, in which case the
# work is balanced across them.
#
# This configuration must be shared between all federation sender workers, and if
# changed all federation sender workers must be stopped at the same time and then
# started, to ensure that all instances are running with the same config (otherwise
# events may be dropped).
#
#federation_sender_instances:
#  - federation_sender1

# When using workers this should be a map from `worker_name` to the
# HTTP replication listener of the worker, if configured.
#
#instance_map:
#  worker1:
#    host: localhost
#    port: 8034

# Experimental: When using workers you can define which workers should
# handle event persistence and typing notifications. Any worker
# specified here must also be in the `instance_map`.
#
#stream_writers:
#  events: worker1
#  typing: worker1

# The worker that is used to run background tasks (e.g. cleaning up expired
# data). If not provided this defaults to the main process.
#
#run_background_tasks_on: worker1

# A shared secret used by the replication APIs to authenticate HTTP requests
# from workers.
#
# By default this is unused and traffic is not authenticated.
#
#worker_replication_secret: ""


# Configuration for Redis when using workers. This *must* be enabled when
# using workers (unless using old style direct TCP configuration).
#
redis:
  # Uncomment the below to enable Redis support.
  #
  #enabled: true

  # Optional host and port to use to connect to redis. Defaults to
  # localhost and 6379
  #
  #host: localhost
  #port: 6379

  # Optional password if configured on the Redis instance
  #
  #password: <secret_password>


# vim:ft=yaml
EOH
        destination = "secrets/homeserver.yaml"
      }

      template {
        data = <<EOH
{{with secret "home/data/robin"}}{{.Data.data.signing_key}}{{end}}
EOH
        destination = "secrets/signing_key"
      }

      template {
        data = <<EOH
version: 1

formatters:
  precise:

    format: '%(asctime)s - %(name)s - %(lineno)d - %(levelname)s - %(request)s - %(message)s'


handlers:


  console:
    class: logging.StreamHandler
    formatter: precise

loggers:
    synapse.storage.SQL:
        # beware: increasing this to DEBUG will make synapse log sensitive
        # information such as access tokens.
        level: INFO

root:
    level: INFO


    handlers: [console]


disable_existing_loggers: false
EOH
        destination = "local/log_config"
      }

      resources {
        cpu = 500
        memory = 300
      }
    }

    task "create-dir" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/create_dir.sh"]
      }

      volume_mount {
        volume = "host"
        destination = "/mnt/host"
        read_only = false
      }

      template {
        data = <<EOH
sudo mkdir -p /mnt/host/robin/data
sudo chmod -R 777 /mnt/host/robin/data
EOH
        destination = "local/create_dir.sh"
        change_mode = "noop"
      }

      lifecycle {
        hook = "prestart"
      }
    }
  }

  group "synapse-db" {
    constraint {
      attribute = "$${attr.unique.hostname}"
      value     = "2c"
    }

    network {
      mode = "bridge"
      port "db" {
        to = 5432
      }
    }

    volume "host" {
      type      = "host"
      source    = "host"
      read_only = false
    }

    service {
      name = "db-robin"
      port = "db"
      address_mode = "alloc"

      connect {
        sidecar_service {}
      }
    }

    task "db" {
      driver = "docker"

      config {
        image = "docker.io/postgres:12-alpine"
        ports = ["db"]
        volumes = [
          "/opt/nomad/volume/robin/db:/var/lib/postgresql/data",
        ]
      }

      env {
        POSTGRES_USER = "robin"
        POSTGRES_DB = "robin"
        POSTGRES_INITDB_ARGS="--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{with secret "database/data/robin"}}{{.Data.data.password}}{{end}}"
EOH
        destination = "secrets/db.env"
        env         = true
      }

      resources {
        cpu = 100
        memory = 50
      }
    }

    task "create-dir" {
      driver = "exec"
      user = "ubuntu"

      config {
        command = "/bin/bash"
        args = ["local/create_dir.sh"]
      }

      volume_mount {
        volume = "host"
        destination = "/mnt/host"
        read_only = false
      }

      template {
        data = <<EOH
sudo mkdir -p /mnt/host/robin/db
sudo chmod -R 777 /mnt/host/robin/db
EOH
        destination = "local/create_dir.sh"
        change_mode = "noop"
      }

      lifecycle {
        hook = "prestart"
      }
    }
  }

  group "synapse-ui" {
    network {
      mode = "bridge"
      port "http" {
        to = 80
      }
    }
    service {
      name = "robin-admin"
      tags = ["traefik.enable=true"]
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "robin"
              local_bind_port  = 8008
            }
          }
        }
      }
    }

    task "synapse-ui" {
      driver = "docker"

      config {
        image = "awesometechnologies/synapse-admin"
        ports = ["http"]
      }

      resources {
        cpu = 100
        memory = 50
      }
    }
  }
}