require 'spec_helper'
describe 'recently_played_playlists_parser' do
  context 'with default values for all parameters' do
    it { should contain_class('recently_played_playlists_parser') }
  end
end
