shared_context "when setting up journey tests" do
  def visit_type_of_properties
    visit domain
    visit "#{domain}/type-of-properties"
    find "h1", text: "What type of certificates do you want data on?"
  end

  def visit_filter_properties
    visit_type_of_properties
    within_fieldset "What type of certificates do you want data on?" do
      choose "Domestic Energy Performance Certificates", allow_label_click: true
    end
    click_button "Continue"
    find "h1", text: "Domestic Energy Performance Certificates"
  end

  def uncheck_efficiency_ratings(ratings: %w[A B C D E F G])
    ratings.each do |rating|
      uncheck "#{rating} rating", allow_label_click: true
    end
  end
end
