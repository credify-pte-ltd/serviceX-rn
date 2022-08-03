export interface serviceXThemeConfig {
  color?: ThemeColor;
  font?: ThemeFont;
  inputFieldRadius?: number;
  modelRadius?: number;
  buttonRadius?: number;
  boxShadow?: string;
}

export interface ThemeFont {
  primaryFontFamily?: string;
  secondaryFontFamily?: string;
  bigTitleFontSize?: number;
  bigTitleFontLineHeight?: number;
  pageHeaderFontSize?: number;
  pageHeaderLineHeight?: number;
  modelTitleFontSize?: number;
  modelTitleFontLineHeight?: number;
  sectionTitleFontSize?: number;
  sectionTitleFontLineHeight?: number;
  sectionTitleSmallFontSize?: number;
  sectionTitleSmallFontLineHeight?: number;
  buttonFontSize?: number;
  buttonFontLineHeight?: number;
  bigFontSize?: number;
  bigFontLineHeight?: number;
  normalFontSize?: number;
  normalFontLineHeight?: number;
  smallFontSize?: number;
  smallFontLineHeight?: number;
  boldFontSize?: number;
  boldFontLineHeight?: number;
}

export interface ThemeColor {
  primaryBrandyStart?: string;
  primaryBrandyEnd?: string;
  primaryText?: string;
  primaryWhite?: string;
  secondaryActive?: string;
  secondaryDisable?: string;
  secondaryText?: string;
  secondaryComponentBackground?: string;
  secondaryBackground?: string;
  primaryButtonTextColor?: string;
  primaryButtonBrandyStart?: string;
  primaryButtonBrandyEnd?: string;
  topBarTextColor?: string;
}
