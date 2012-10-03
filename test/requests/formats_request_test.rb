require 'test_helper'
require "gds_api/test_helpers/licence_application"

class FormatsRequestTest < GovUkContentApiTest
  include GdsApi::TestHelpers::LicenceApplication

  def setup
    super
    @tag1 = FactoryGirl.create(:tag, tag_id: 'crime')
    @tag2 = FactoryGirl.create(:tag, tag_id: 'crime/batman')
  end

  def _assert_base_response_info(parsed_response)
    assert_equal 'ok', parsed_response["_response_info"]["status"]
    assert parsed_response.has_key?('title')
    assert parsed_response.has_key?('id')
    assert parsed_response.has_key?('tags')
  end

  def _assert_has_expected_fields(parsed_response, fields)
    fields.each do |field|
      assert parsed_response.has_key?(field), "Field #{field} is MISSING"
    end
  end

  it "should work with answer_edition" do
    artefact = FactoryGirl.create(:artefact, slug: 'batman', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    answer = FactoryGirl.create(:edition, slug: artefact.slug, body: 'Important batman information', panopticon_id: artefact.id, state: 'published')

    get '/batman.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]

    expected_fields = ['alternative_title', 'overview', 'body']

    _assert_has_expected_fields(fields, expected_fields)
    assert_equal "<p>Important batman information</p>\n", fields["body"]
  end

  it "should work with business_support_edition" do
    artefact = FactoryGirl.create(:artefact, slug: 'batman', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    business_support = FactoryGirl.create(:business_support_edition, slug: artefact.slug,
                                short_description: "No policeman's going to give the Batmobile a ticket", min_value: 100,
                                max_value: 1000, panopticon_id: artefact.id, state: 'published',
                                business_support_identifier: 'enterprise-finance-guarantee', max_employees: 10,
                                organiser: "Someone", continuation_link: "http://www.example.com/scheme", will_continue_on: "Example site",
                                contact_details: "Someone, somewhere")
    business_support.save!

    get '/batman.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]
    expected_fields = ['alternative_title', 'overview', 'body',
                        'short_description', 'min_value', 'max_value', 'eligibility', 'evaluation', 'additional_information',
                        'business_support_identifier', 'max_employees', 'organiser', 'continuation_link', 'will_continue_on', 'contact_details']
    _assert_has_expected_fields(fields, expected_fields)
    assert_equal "No policeman's going to give the Batmobile a ticket", fields['short_description']
    assert_equal "enterprise-finance-guarantee", fields['business_support_identifier']
  end

  it "should work with guide_edition" do
    artefact = FactoryGirl.create(:artefact, slug: 'batman', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    guide_edition = FactoryGirl.create(:guide_edition_with_two_govspeak_parts, slug: artefact.slug,
                                panopticon_id: artefact.id, state: 'published')
    guide_edition.save!

    get '/batman.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]
    expected_fields = ['alternative_title', 'overview', 'parts']

    _assert_has_expected_fields(fields, expected_fields)
    refute fields.has_key?('body')
    assert_equal "Some Part Title!", fields['parts'][0]['title']
    assert_equal "<p>This is some <strong>version</strong> text.</p>\n", fields['parts'][0]['body']
    assert_equal "http://www.test.gov.uk/batman/part-one", fields['parts'][0]['web_url']
    assert_equal "part-one", fields['parts'][0]['slug']
  end

  it "should work with programme_edition" do
    artefact = FactoryGirl.create(:artefact, slug: 'batman', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    programme_edition = FactoryGirl.create(:programme_edition, slug: artefact.slug,
                                panopticon_id: artefact.id, state: 'published')
    programme_edition.save!

    get '/batman.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]
    expected_fields = ['alternative_title', 'overview', 'parts']

    _assert_has_expected_fields(fields, expected_fields)
    refute fields.has_key?('body')
    assert_equal "Overview", fields['parts'][0]['title']
    assert_equal "http://www.test.gov.uk/batman/overview", fields['parts'][0]['web_url']
    assert_equal "overview", fields['parts'][0]['slug']
  end

  it "should work with video_edition" do
    artefact = FactoryGirl.create(:artefact, slug: 'batman', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    video_edition = FactoryGirl.create(:video_edition, title: 'Video killed the radio star', panopticon_id: artefact.id, slug: artefact.slug,
                                       video_summary: 'I am a video summary', video_url: 'http://somevideourl.com',
                                       body: "Video description\n------", state: 'published')

    get '/batman.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]

    expected_fields = %w(alternative_title overview video_url video_summary body)

    _assert_has_expected_fields(fields, expected_fields)
    assert_equal "I am a video summary", fields["video_summary"]
    assert_equal "http://somevideourl.com", fields["video_url"]
    assert_equal "<h2>Video description</h2>\n", fields["body"]
  end

  it "should work with licence_edition" do
    artefact = FactoryGirl.create(:artefact, slug: 'batman-licence', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    licence_edition = FactoryGirl.create(:licence_edition, slug: artefact.slug, licence_short_description: 'Batman licence',
                                licence_overview: 'Not just anyone can be Batman', panopticon_id: artefact.id, state: 'published',
                                will_continue_on: 'The Batman', continuation_link: 'http://www.batman.com', licence_identifier: "123-4-5")
    licence_exists('123-4-5', { })

    get '/batman-licence.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]
    expected_fields = ['alternative_title', 'licence_overview', 'licence_short_description', 'licence_identifier', 'will_continue_on', 'continuation_link']

    _assert_has_expected_fields(fields, expected_fields)
    assert_equal "Not just anyone can be Batman", fields["licence_overview"]
    assert_equal "Batman licence", fields["licence_short_description"]
  end

  it "should work with local_transaction_edition" do
    service = FactoryGirl.create(:local_service)
    expectation = FactoryGirl.create(:expectation)
    artefact = FactoryGirl.create(:artefact, slug: 'batman-transaction', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    local_transaction_edition = FactoryGirl.create(:local_transaction_edition, slug: artefact.slug, lgil_override: 3345,
                                expectation_ids: [expectation.id], minutes_to_complete: 3,
                                panopticon_id: artefact.id, state: 'published')
    get '/batman-transaction.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]
    expected_fields = ['alternative_title', 'lgsl_code', 'lgil_override', 'introduction', 'more_information',
                        'minutes_to_complete', 'expectation_ids']

    _assert_has_expected_fields(fields, expected_fields)
  end

  it "should work with transaction_edition" do
    expectation = FactoryGirl.create(:expectation)
    artefact = FactoryGirl.create(:artefact, slug: 'batman-transaction', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    transaction_edition = FactoryGirl.create(:transaction_edition, slug: artefact.slug,
                                expectation_ids: [expectation.id], minutes_to_complete: 3,
                                panopticon_id: artefact.id, state: 'published')
    get '/batman-transaction.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]
    expected_fields = ['alternate_methods', 'will_continue_on', 'link', 'introduction', 'more_information',
                        'expectation_ids']

    _assert_has_expected_fields(fields, expected_fields)
  end

  it "should work with place_edition" do
    expectation = FactoryGirl.create(:expectation)
    artefact = FactoryGirl.create(:artefact, slug: 'batman-place', owning_app: 'publisher', sections: [@tag1.tag_id], state: 'live')
    place_edition = FactoryGirl.create(:place_edition, slug: artefact.slug, expectation_ids: [expectation.id],
                                minutes_to_complete: 3, panopticon_id: artefact.id, state: 'published')
    get '/batman-place.json'
    parsed_response = JSON.parse(last_response.body)

    assert last_response.ok?
    _assert_base_response_info(parsed_response)

    fields = parsed_response["details"]
    expected_fields = ['introduction', 'more_information', 'place_type', 'expectation_ids']

    _assert_has_expected_fields(fields, expected_fields)
  end

end
