require_relative '../test_helper'
require 'gds_api/test_helpers/asset_manager'

class SpecialistDocumentTest < GovUkContentApiTest
  describe "loading a published specialist document" do
    def build_specialist_document_edition!(body = "This is the body")
      @artefact = FactoryGirl.create(:artefact,
        slug: "mhra-drug-alerts/private-healthcare-investigation",
        state: "live",
        kind: "specialist-document",
        owning_app: "specialist-publisher",
        name: "Private Healthcare Investigation"
      )
      @edition = FactoryGirl.create(:specialist_document_edition,
        slug: "mhra-drug-alerts/private-healthcare-investigation",
        title: "Private Healthcare Investigation",
        summary: "This is the summary",
        body: body,
        state: "published",
        opened_date: Date.parse("2013-03-21"),
        closed_date: nil,
        case_type: "market-investigation",
        case_state: "open",
        market_sector: "healthcare",
        outcome_type: "referred",
        document_id: "doesnt-matter-here"
      )
    end

    it "should return a successful response" do
      build_specialist_document_edition!
      get '/mhra-drug-alerts/private-healthcare-investigation.json'
      assert last_response.ok?
    end

    it "should return json containing the published edition" do
      build_specialist_document_edition!
      get '/mhra-drug-alerts/private-healthcare-investigation.json'
      parsed_response = JSON.parse(last_response.body)

      assert_base_artefact_fields(parsed_response)
      assert_equal 'specialist_document', parsed_response["format"]
      assert_equal 'Private Healthcare Investigation', parsed_response["title"]
      assert_equal 'This is the summary', parsed_response["details"]["summary"]
      assert_equal '2013-03-21', parsed_response["details"]["opened_date"]
      assert_equal nil, parsed_response["details"]["closed_date"]
      assert_equal "market-investigation", parsed_response["details"]["case_type"]
      assert_equal "open", parsed_response["details"]["case_state"]
      assert_equal "healthcare", parsed_response["details"]["market_sector"]
      assert_equal "referred", parsed_response["details"]["outcome_type"]
    end

    it "should provide hierarchical headers for the document body" do
      body = [
        "## Heading",
        "### Subheading",
        ""
      ].join("\n\n")

      build_specialist_document_edition!(body)

      expected_headers = [
        {
          "text" => "Heading",
          "id" => "heading",
          "level" => 2,
          "headers" => [
            {
              "text" => "Subheading",
              "id" => "subheading",
              "level" => 3,
              "headers" => []
            }
          ]
        }
      ]

      get "#{@artefact.slug}.json"

      if last_response.ok?
        actual_headers = JSON.parse(last_response.body).fetch("details").fetch("headers")

        assert_equal expected_headers, actual_headers
      else
        fail "RESPONSE: #{last_response.status}" + last_response.body
      end
    end
  end

  describe "artefact but no edition" do
    before do
      FactoryGirl.create(:artefact,
        slug: "mhra-drug-alerts/private-healthcare-investigation",
        state: "live",
        kind: "specialist-document",
        owning_app: "specialist-publisher",
        name: "Private Healthcare Investigation"
      )
    end

    it "should return 404 response" do
      get '/mhra-drug-alerts/private-healthcare-investigation.json'
      assert last_response.not_found?
    end
  end

  describe "artefact but no published edition" do
    before do
      @artefact = FactoryGirl.create(:artefact,
        slug: "mhra-drug-alerts/private-healthcare-investigation",
        state: "live",
        kind: "specialist-document",
        owning_app: "specialist-publisher",
        name: "Private Healthcare Investigation"
      )
      @edition = FactoryGirl.create(:specialist_document_edition,
        slug: "mhra-drug-alerts/private-healthcare-investigation",
        title: "Private Healthcare Investigation",
        state: "draft",
        document_id: "doesnt-matter-here"
      )
    end

    it "should return 404 response" do
      get '/mhra-drug-alerts/private-healthcare-investigation.json'
      assert last_response.not_found?
    end
  end
end
