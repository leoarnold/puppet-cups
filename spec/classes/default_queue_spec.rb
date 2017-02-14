require 'spec_helper'

describe 'cups::default_queue' do
  context 'with attribute' do
    describe 'queue' do
      context 'not provided' do
        it { expect { should compile }.to raise_error(/queue/) }
      end

      context 'set to a string with international characters, numbers and underscores' do
        let(:queue) { 'RSpec_Test_äöü_абв_Nr1' }

        context "and the catalog contains the corresponding 'cups_queue' resource" do
          let(:params) { { queue: queue } }

          let(:pre_condition) { "cups_queue { '#{queue}': }" }

          it { should compile }

          it { should contain_class('cups::default_queue').with(queue: queue) }

          it { should contain_exec("lpadmin -E -d '#{queue}'").with(command: "lpadmin -E -d '#{queue}'") }

          it { should contain_exec("lpadmin -E -d '#{queue}'").with(unless: "lpstat -d | grep -w '#{queue}'") }

          it { should contain_exec("lpadmin -E -d '#{queue}'").that_requires("Cups_queue[#{queue}]") }
        end

        context "but the catalog does NOT contain the corresponding 'cups_queue' resource" do
          let(:params) { { queue: queue } }

          it { expect { should compile }.to raise_error(/dependency/) }
        end
      end

      context 'set to a string with a SPACE' do
        let(:params) { { queue: 'RSpec Test_Printer' } }

        it { expect { should compile }.to raise_error(/SPACE/) }
      end

      context 'set to a string with a TAB' do
        let(:params) { { queue: "RSpec\tTest_Printer" } }

        it { expect { should compile }.to raise_error(/TAB/) }
      end

      context 'set to a string with a carriage return character' do
        let(:params) { { queue: "RSpec\rTest_Printer" } }

        it { expect { should compile }.to raise_error(/SPACE/) }
      end

      context 'set to a string with a newline character' do
        let(:params) { { queue: "RSpec\nTest_Printer" } }

        it { expect { should compile }.to raise_error(/SPACE/) }
      end

      context 'set to a string with a SLASH' do
        let(:params) { { queue: 'RSpec/Test_Printer' } }

        it { expect { should compile }.to raise_error(/SLASH/) }
      end

      context 'set to a string with a BACKSLASH' do
        let(:params) { { queue: 'RSpec\Test_Printer' } }

        it { expect { should compile }.to raise_error(/BACK[)]?SLASH/) }
      end

      context 'set to a string with a SINGLEQUOTE' do
        let(:params) { { queue: "RSpec'Test_Printer" } }

        it { expect { should compile }.to raise_error(/QUOTE/) }
      end

      context 'set to a string with a DOUBLEQUOTE' do
        let(:params) { { queue: 'RSpec"Test_Printer' } }

        it { expect { should compile }.to raise_error(/QUOTE/) }
      end

      context 'set to a string with a COMMA' do
        let(:params) { { queue: 'RSpec,Test_Printer' } }

        it { expect { should compile }.to raise_error(/COMMA/) }
      end

      context "set to a string with a '#'" do
        let(:params) { { queue: 'RSpec#Test_Printer' } }

        it { expect { should compile }.to raise_error(/#/) }
      end
    end
  end
end
