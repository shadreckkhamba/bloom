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
    "nude"       => "#E8C9A0",
    "dusty sage green"  => "#8FAF88",
    "light sage green"  => "#B2C9AD",
    "blush pink"        => "#DE9FA1",
    "pale blush pink"   => "#F2C4C4",
  }.freeze

  LIGHT_SWATCH_COLORS = [
    "white",
    "ivory",
    "light blue",
    "lightblue",
    "nude",
    "champagne",
    "peach",
    "blush",
    "blush pink",
    "pale blush pink"
  ].freeze

  FIXED_WEDDING_PALETTE = [
    { name: "Light Blue", key: "light-blue" },
    { name: "Black",      key: "black" },
    { name: "White",      key: "white" },
    { name: "Nude",       key: "nude" }
  ].freeze

  def fixed_wedding_palette
    FIXED_WEDDING_PALETTE
  end

  def color_swatch_style(color_name)
    key = color_name.to_s.downcase.strip
    hex = COLOR_MAP[key]
    bg  = hex || color_name # fall back to raw value (e.g. a CSS colour word)

    if LIGHT_SWATCH_COLORS.include?(key)
      "background-color:#{bg};border:1px solid rgba(0,0,0,0.42);box-shadow:inset 0 0 0 1px rgba(255,255,255,0.55), 0 1px 4px rgba(0,0,0,0.18);"
    else
      "background-color:#{bg};border:1px solid rgba(0,0,0,0.14);"
    end
  end
end
