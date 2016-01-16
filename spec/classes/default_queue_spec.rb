require 'spec_helper'

describe 'cups::default_queue' do
  let(:pre_condition) do
    <<-EOM
      class{ '::cups': }

      cups_queue { 'Office':
        ensure => 'printer',
        model  => 'drv:///sample.drv/generic.ppd',
        uri    => 'lpd://192.168.2.105/binary_p1'
      }
    EOM
  end

  let(:params) do
    {
      queue: 'Office'
    }
  end

  it { should contain_class('cups::default_queue') }

  it { should contain_exec('lpadmin-d').that_requires('Cups_queue[Office]') }
end
