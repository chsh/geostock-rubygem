# -*- coding: UTF-8 -*-

require "spec_helper"

describe GeoStock::API do

  before(:each) do
    @api_token = ENV['GEOSTOCK_API_TOKEN']
    @api_secret_token = ENV['GEOSTOCK_API_SECRET']
    GeoStock::API::REQUEST_URI_BASE = ENV['GEOSTOCK_API_REQUEST_BASE']
    @api = GeoStock::API.new @api_token, @api_secret_token
    @api.delete_collections 'hello', 'world'
  end

  after(:each) do
    @api.delete_collections 'hello', 'world'
  end

  it 'should manipulate collections' do
    @api.collections.should == []
    @api.create_collections 'hello', 'world'
    @api.collections.should == ['hello', 'world']
    @api.delete_collections 'hello'
    @api.collections.should == ['world']
    @api.delete_collections 'world'
    @api.collections.should == []
  end

  it 'should manipulate pois.' do
    @api = GeoStock::API.new @api_token, @api_secret_token
    @api.create_collection 'world'
    @api.update_pois 'world', [
      {uid: '123', ll: '38.111234,138.44555', attrs: {
          url: 'http://www.yahoo.co.jp/',
          title: 'ほんじゃまか',
          desc: '解説文'
        }
      }
    ]
    @api.update_pois 'world', [
      {uid: '124', ll: '38.111234,138.445551', attrs: {
          url: 'http://www.yahoo.co.jp/',
          title: 'メロン',
          desc: 'くだもの'
        }
      }
    ]
    poi_not_found = @api.get_poi('world', '125')
    poi_not_found.code.should == '404'
    poi_data = @api.get_poi('world', '124')
    poi_data.should == {
        'uid' =>'124',
        'attrs' => { 'url' => 'http://www.yahoo.co.jp/',
          'title' => 'メロン',
          'desc' => 'くだもの'
        },
        'll' => '38.111234,138.445551'
    }

    pois = @api.get_all_pois('world')
    pois.should == [
        {'uid' => '123', 'll' => '38.111234,138.44555', 'attrs' => {
            'url' => 'http://www.yahoo.co.jp/',
            'title' => 'ほんじゃまか',
            'desc' => '解説文'
          }
        },
        {'uid' => '124', 'll' => '38.111234,138.445551', 'attrs' => {
            'url' => 'http://www.yahoo.co.jp/',
            'title' => 'メロン',
            'desc' => 'くだもの'
          }
        }
    ]
  end
end
