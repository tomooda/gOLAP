Extension { #name : 'StFontChooserPresenter' }

{ #category : '*Golap-UI' }
StFontChooserPresenter >> updateFonts [

	FreeTypeFontProvider current updateFromSystem.
	self model
		fontList: LogicalFontManager current allFamilies;
		yourself.

	self updateWithFont: self selectedFont
]
