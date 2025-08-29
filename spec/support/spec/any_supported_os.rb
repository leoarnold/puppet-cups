# frozen_string_literal: true

def any_supported_os(more_facts = {})
  {
    os: {
      family: 'Debian',
      name: 'Debian',
      release: {
        full: '12.0',
        major: '12',
        minor: '0'
      },
      distro: {
        codename: 'bookworm',
        description: 'Debian GNU/Linux 12 (bookworm)',
        id: 'Debian',
        release: {
          full: '12.0',
          major: '12',
          minor: '0'
        },
      },
    },
    path: '/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/opt/puppetlabs/bin',
  }.merge(more_facts)
end
