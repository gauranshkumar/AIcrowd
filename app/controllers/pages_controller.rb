class PagesController < ApplicationController
  def contact
    @page_title = "Contact"
  end

  def privacy
    @page_title = "Privacy"
  end

  def terms
    @page_title = "Terms of Use"
  end

  def faq
    @page_title = "FAQ"
  end

  def cookies_info
    @page_title = "Cookies"
  end

  def community_guidelines
    @page_title = "Community Guidelines"
  end

  def ai_ethics
    @page_title = "AI & Ethics"
  end

  def ai_ethics
    @page_title = "Bug & Bounty"
  end
end
