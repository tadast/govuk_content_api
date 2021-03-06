class GroupedResultSetPresenter < ResultSetPresenter
  def present
    paginated_response_base.merge(
      "grouped_results" => grouped_results.map do |(group,formats), results|
        {
          "name" => group,
          "formats" => formats,
          "items" => results.map {|result|
            @result_presenter_class.new(result, @url_helper).present
          }
        }
      end
    )
  end

  private
  def grouped_results
    # split the result set into groups. the group is determined by
    # looking up the format in the hash returned from display_groups
    grouped_results = @result_set.results.group_by {|a|
      display_groups.detect {|group, formats| formats.include?(a.kind) }
    }

    # For now, exclude results with format that isn't in the list
    grouped_results_without_other_formats = grouped_results.reject {|group|
      group.nil?
    }

    # force the order of groups as they're defined in the hash from the
    # display_groups method below
    grouped_results_without_other_formats.sort_by {|(name, formats), items|
      display_groups.keys.index(name)
    }
  end

  def display_groups
    {
      "Services" => ["answer", "guide", "licence", "transaction"],
      "Statutory guidance" => ["statutory_guidance"],
      "Guidance" => ["guidance", "detailed_guide"],
      "Document collections" => ["document_collection"],
      "Forms" => ["form"],
      "Maps" => ["map"],
      "Statistics" => ["statistics", "statistical_data_set"],
      "Research and analysis" => ["research"],
      "Independent reports" => ["independent_report"],
      "Impact assessments" => ["impact_assessment"],
      "Policy papers" => ["policy_paper"],
      "Consultations" => ["consultation"],
      "Announcements" => [
        "transcript",
        "draft_text",
        "speaking_notes",
        "written_statement",
        "oral_statement",
        "authored_article",
        "news_story",
        "press_release",
        "government_response",
        "world_location_news_article"
      ]
    }
  end
end
