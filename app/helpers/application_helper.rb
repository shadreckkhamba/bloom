module ApplicationHelper
  def app_name
    Rails.configuration.x.app_name
  end

  def app_signature
    Rails.configuration.x.app_signature
  end

  # Maps a wedding colour name to a CSS background string for the swatch chip.
  COLOR_MAP = {
    "black"      => "#1a1a1a",
    "white"      => "#ffffff",
    "ivory"      => "#FFFFF0",
    "light blue" => "#ADD8E6",
    "lightblue"  => "#ADD8E6",
    "navy"       => "#001F5B",
    "gold"       => "#C9A84C",
    "silver"     => "#C0C0C0",
    "pink"       => "#FFB6C1",
    "rose"       => "#FF007F",
    "red"        => "#CC0000",
    "burgundy"   => "#800020",
    "green"      => "#228B22",
    "sage"       => "#B2C9AD",
    "lavender"   => "#E6E6FA",
    "purple"     => "#800080",
    "blush"      => "#DE9FA1",
    "champagne"  => "#F7E7CE",
    "peach"      => "#FFCBA4",
  }.freeze

  def color_swatch_style(color_name)
    hex = COLOR_MAP[color_name.downcase.strip]
    bg  = hex || color_name  # fall back to raw value (e.g. a CSS colour word)
    border = (color_name.downcase.strip == "white" || color_name.downcase.strip == "ivory") ? "border:1px solid #ddd;" : ""
    "background:#{bg};#{border}"
  end
end
