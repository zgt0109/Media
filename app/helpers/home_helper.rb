module HomeHelper
  def available_solutions
    @available_solutions ||= HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/solutions.yml") || {})
  end
  def detected_solutions_by_name(name)
    available_solutions.values.collect{|s| s[:cases]}.flatten.compact.detect{|s| s["name"].eql?(name)}
  end

  def recommend_solutions
    recommend_solution_names = %w(滨江国际广场 永安保险 洋河1号 锦江旅游在线 福馨西饼)

    recommend_solution_names.collect{|name| detected_solutions_by_name(name)}.compact
  end

  def solution_li_class(name)
    html = ""
    i_classes = ["cc-visa","birthday-cake","cart-plus","building-o","diamond","graduation-cap",
      "hospital-o","bank","car","sitemap","user-md", "truck"]
    Case.nav_module_default_categories.each_with_index do |c,i|
      html << %Q(
                  <li class="#{'nav-cur' if name == 'category'+c[1].to_s}">
                    <a href="#{solution_path(name: 'category'+c[1].to_s)}">
                    <i class="fa fa-#{i_classes[i]}"></i>
                    <span>#{c[0]}</span>
                    </a>
                  </li>
                )
    end
    html.html_safe
  end
end
